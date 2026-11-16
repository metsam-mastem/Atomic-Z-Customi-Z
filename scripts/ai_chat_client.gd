extends Node
class_name AIChatClient

## Minimal asynchronous chat adapter for Ollama and OpenAI-compatible endpoints.
## Do not embed API keys in project files or commit them to Git.
signal response_received(text: String)
signal request_failed(message: String)

@export var timeout_seconds := 45.0

func chat(provider: Dictionary, model_id: String, messages: Array[Dictionary], api_key_env_var := "") -> Dictionary:
	var kind := str(provider.get("kind", ""))
	var base_url := AIModelRegistry.normalize_base_url(str(provider.get("base_url", "")))
	var endpoint := str(provider.get("chat_endpoint", "/api/chat"))
	if base_url.is_empty() or model_id.strip_edges().is_empty():
		return _fail("Provider URL and model ID are required.")
	if kind not in ["ollama", "openai_compatible"]:
		return _fail("Unsupported provider kind.")
	var url := base_url + endpoint
	var payload: Dictionary
	if kind == "ollama":
		payload = {"model": model_id, "messages": messages, "stream": false}
	else:
		payload = {"model": model_id, "messages": messages, "stream": false}
	var headers := PackedStringArray(["Content-Type: application/json"])
	if kind == "openai_compatible":
		if api_key_env_var.strip_edges().is_empty():
			return _fail("Set an environment variable name for the API key; no key is embedded.")
		var api_key := OS.get_environment(api_key_env_var)
		if api_key.is_empty():
			return _fail("API key environment variable is not set: " + api_key_env_var)
		headers.append("Authorization: Bearer " + api_key)
	var request_node := HTTPRequest.new()
	request_node.timeout = timeout_seconds
	add_child(request_node)
	var err := request_node.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(payload))
	if err != OK:
		request_node.queue_free()
		return _fail("HTTP request could not start. Error code: " + str(err))
	var result: Array = await request_node.request_completed
	request_node.queue_free()
	var request_result := int(result[0])
	var status_code := int(result[1])
	var body_bytes: PackedByteArray = result[3]
	if request_result != HTTPRequest.RESULT_SUCCESS:
		return _fail("Network request failed. Check endpoint, connectivity, and timeout.")
	if status_code < 200 or status_code >= 300:
		return _fail("Provider returned HTTP " + str(status_code) + ".")
	var parsed: Variant = JSON.parse_string(body_bytes.get_string_from_utf8())
	if not parsed is Dictionary:
		return _fail("Provider response was not a JSON object.")
	var answer := ""
	if kind == "ollama":
		answer = str(parsed.get("message", {}).get("content", ""))
	else:
		var choices: Array = parsed.get("choices", [])
		if not choices.is_empty():
			answer = str(choices[0].get("message", {}).get("content", ""))
	if answer.strip_edges().is_empty():
		return _fail("No text content found in provider response.")
	response_received.emit(answer)
	return {"ok": true, "text": answer, "status_code": status_code}

func _fail(message: String) -> Dictionary:
	request_failed.emit(message)
	return {"ok": false, "error": message}
