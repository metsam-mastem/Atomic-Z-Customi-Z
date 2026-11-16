extends Node
class_name AIChatClient

## Optional asynchronous adapter for local Ollama and HTTPS OpenAI-compatible APIs.
## API keys are read from desktop development environment variables only; never persisted.
signal response_received(text: String)
signal request_failed(message: String)

const AIModelRegistryScript = preload("res://scripts/ai_model_registry.gd")
const MAX_REQUEST_BYTES := 65536
const MAX_RESPONSE_BYTES := 1048576
const MAX_MESSAGES := 12
const MAX_MESSAGE_CHARS := 8000

@export_range(5.0, 120.0, 1.0) var timeout_seconds := 45.0

var _active_request: HTTPRequest
var _busy := false

func is_busy() -> bool:
	return _busy

func cancel_active_request() -> bool:
	if not is_instance_valid(_active_request):
		return false
	_active_request.cancel_request()
	return true

func chat(provider: Dictionary, model_id: String, messages: Array[Dictionary], api_key_env_var: String = "", allow_local_http: bool = false) -> Dictionary:
	if _busy:
		return _fail("A request is already in progress.")
	if model_id.strip_edges().is_empty():
		return _fail("Enter a model ID available at the selected provider.")
	if messages.is_empty() or messages.size() > MAX_MESSAGES:
		return _fail("Conversation must contain between 1 and 12 messages.")

	var key_name := api_key_env_var.strip_edges()
	if not key_name.is_empty():
		var key_name_regex := RegEx.new()
		key_name_regex.compile("^[A-Za-z_][A-Za-z0-9_]*$")
		if key_name_regex.search(key_name) == null:
			return _fail("API key environment variable name is invalid.")
		if OS.has_feature("android"):
			return _fail("Hosted API keys are disabled in Android builds until a secure credential service is available.")

	var api_key := OS.get_environment(key_name) if not key_name.is_empty() else ""
	if not key_name.is_empty() and api_key.is_empty():
		return _fail("The requested desktop environment variable is not set.")
	if not api_key.is_empty() and str(provider.get("kind", "")) == "ollama":
		return _fail("Do not send hosted API keys to a local Ollama endpoint.")
	var target_check: Dictionary = AIModelRegistryScript.validate_request_target(
		provider,
		allow_local_http,
		OS.has_feature("android"),
		not api_key.is_empty()
	)
	if not target_check.get("ok", false):
		return _fail(str(target_check.get("error", "Provider URL was rejected.")))

	var normalized_messages: Array[Dictionary] = []
	var total_chars := 0
	for message_value in messages:
		if not (message_value is Dictionary):
			return _fail("Conversation contains an invalid message.")
		var role := str(message_value.get("role", ""))
		var content_value: Variant = message_value.get("content", null)
		if role not in ["system", "user", "assistant"] or not (content_value is String):
			return _fail("Conversation message roles or content are invalid.")
		var message_text := str(content_value)
		if message_text.length() > MAX_MESSAGE_CHARS:
			return _fail("A conversation message exceeds the 8,000 character limit.")
		total_chars += message_text.length()
		normalized_messages.append({"role": role, "content": message_text})
	if total_chars > MAX_REQUEST_BYTES / 2:
		return _fail("Conversation is too large. Clear the chat or shorten the prompt.")

	var kind := str(provider.get("kind", ""))
	var payload := {
		"model": model_id.strip_edges(),
		"messages": normalized_messages,
		"stream": false
	}
	var request_body := JSON.stringify(payload)
	if request_body.to_utf8_buffer().size() > MAX_REQUEST_BYTES:
		return _fail("Request exceeds the 64 KiB safety limit.")

	var headers := PackedStringArray(["Content-Type: application/json"])
	if not api_key.is_empty():
		headers.append("Authorization: Bearer " + api_key)
	var url := str(target_check["base_url"]) + str(provider.get("chat_endpoint", ""))
	if not url.begins_with("https://") and not (kind == "ollama" and allow_local_http):
		return _fail("Request transport policy rejected the endpoint.")

	var request_node := HTTPRequest.new()
	request_node.timeout = timeout_seconds
	request_node.body_size_limit = MAX_RESPONSE_BYTES
	request_node.max_redirects = 0
	add_child(request_node)
	_active_request = request_node
	_busy = true
	var start_error := request_node.request(url, headers, HTTPClient.METHOD_POST, request_body)
	if start_error != OK:
		_cleanup_request(request_node)
		return _fail("HTTP request could not start. Error code: " + str(start_error))

	var result: Array = await request_node.request_completed
	_cleanup_request(request_node)
	var request_result := int(result[0])
	var status_code := int(result[1])
	var body_bytes: PackedByteArray = result[3]
	if request_result != HTTPRequest.RESULT_SUCCESS:
		return _fail("Network request failed or was cancelled. Check the endpoint, trust boundary and timeout.")
	if status_code < 200 or status_code >= 300:
		return _fail("Provider returned HTTP " + str(status_code) + ".")
	if body_bytes.size() > MAX_RESPONSE_BYTES:
		return _fail("Provider response exceeds the 1 MiB safety limit.")

	var parsed: Variant = JSON.parse_string(body_bytes.get_string_from_utf8())
	if not (parsed is Dictionary):
		return _fail("Provider response was not a JSON object.")
	var answer := ""
	if kind == "ollama":
		var ollama_message_value: Variant = parsed.get("message", {})
		if ollama_message_value is Dictionary:
			answer = str(ollama_message_value.get("content", ""))
	else:
		var choices_value: Variant = parsed.get("choices", [])
		if choices_value is Array and not choices_value.is_empty() and choices_value[0] is Dictionary:
			var choice_message_value: Variant = choices_value[0].get("message", {})
			if choice_message_value is Dictionary:
				answer = str(choice_message_value.get("content", ""))
	if answer.strip_edges().is_empty():
		return _fail("No text content found in provider response.")
	response_received.emit(answer)
	return {"ok": true, "text": answer, "status_code": status_code}

func _cleanup_request(request_node: HTTPRequest) -> void:
	if is_instance_valid(request_node):
		request_node.queue_free()
	_active_request = null
	_busy = false

func _fail(message: String) -> Dictionary:
	request_failed.emit(message)
	return {"ok": false, "error": message}
