extends SceneTree

const AIChatClientScript = preload("res://scripts/ai_chat_client.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var client := AIChatClientScript.new()
	root.add_child(client)

	var valid_provider := {
		"id": "openai_compatible",
		"name": "Test endpoint",
		"kind": "openai_compatible",
		"base_url": "https://api.example.invalid",
		"chat_endpoint": "/v1/chat/completions"
	}
	var one_message: Array[Dictionary] = [{"role": "user", "content": "hello"}]

	var empty_model: Dictionary = await client.chat(valid_provider, "", one_message)
	_assert(not empty_model.get("ok", false), "Empty model IDs must fail before network access.")

	var empty_endpoint := valid_provider.duplicate(true)
	empty_endpoint["base_url"] = ""
	var bad_endpoint: Dictionary = await client.chat(empty_endpoint, "test-model", one_message)
	_assert(not bad_endpoint.get("ok", false), "Missing endpoints must fail before network access.")

	var invalid_role: Array[Dictionary] = [{"role": "developer", "content": "do not accept"}]
	var bad_role: Dictionary = await client.chat(valid_provider, "test-model", invalid_role)
	_assert(not bad_role.get("ok", false), "Unsupported message roles must be rejected.")

	var too_many: Array[Dictionary] = []
	for index in range(13):
		too_many.append({"role": "user", "content": "message " + str(index)})
	var oversized_conversation: Dictionary = await client.chat(valid_provider, "test-model", too_many)
	_assert(not oversized_conversation.get("ok", false), "Conversations over 12 messages must be rejected.")

	var invalid_key_name: Dictionary = await client.chat(valid_provider, "test-model", one_message, "BAD-ENV-NAME")
	_assert(not invalid_key_name.get("ok", false), "Invalid environment variable names must be rejected.")

	_assert(not client.is_busy(), "Rejected preflight requests must not leave the client busy.")
	_assert(not client.cancel_active_request(), "Cancellation without an active request must be a no-op.")

	if _failed:
		quit(1)
	else:
		print("PASS: AI client preflight validation, bounded conversation and idle cancellation.")
		quit(0)

var _failed := false

func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error(message)
