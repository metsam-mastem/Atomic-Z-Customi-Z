extends SceneTree

const Registry = preload("res://scripts/ai_model_registry.gd")

var _failed := false

func _initialize() -> void:
	_run()

func _run() -> void:
	var providers: Array[Dictionary] = Registry.get_builtin_providers()
	_assert(providers.size() == 2, "Built-in provider catalog must be the source for the UI.")
	_assert(providers[0].get("kind") == "ollama", "Ollama must be available as the free-first provider.")
	_assert(providers[1].get("kind") == "openai_compatible", "Generic OpenAI-compatible endpoints must support additional model families.")

	var ollama := {
		"id": "ollama",
		"name": "Ollama",
		"kind": "ollama",
		"base_url": "http://192.168.1.20:11434",
		"chat_endpoint": "/api/chat"
	}
	_assert(Registry.validate_request_target(ollama, false, false).get("ok", false) == false, "Ollama HTTP must be denied until the user explicitly opts in.")
	_assert(Registry.validate_request_target(ollama, true, false).get("ok", false), "Explicit private-LAN Ollama HTTP must be allowed without credentials.")
	_assert(not Registry.validate_request_target(ollama, true, false, true).get("ok", false), "Credentials must never be sent over cleartext HTTP.")
	_assert(Registry.validate_request_target(ollama, true, true).get("ok", false), "Android must accept a configured private LAN host."

	var loopback := ollama.duplicate(true)
	loopback["base_url"] = "http://127.0.0.1:11434"
	_assert(not Registry.validate_request_target(loopback, true, true).get("ok", false), "Android loopback must be rejected because it points to the phone.")
	_assert(Registry.validate_request_target(loopback, true, false).get("ok", false), "Desktop loopback is a valid local Ollama host.")

	var public_http := ollama.duplicate(true)
	public_http["base_url"] = "http://203.0.113.7:11434"
	_assert(not Registry.validate_request_target(public_http, true, false).get("ok", false), "Cleartext Ollama must reject public IP addresses.")

	var hosted := {
		"id": "openai_compatible",
		"name": "Hosted API",
		"kind": "openai_compatible",
		"base_url": "https://api.example.invalid",
		"chat_endpoint": "/v1/chat/completions"
	}
	_assert(Registry.validate_request_target(hosted, false, false).get("ok", false), "Hosted OpenAI-compatible endpoints must accept HTTPS.")
	hosted["base_url"] = "http://api.example.invalid"
	_assert(not Registry.validate_request_target(hosted, true, false).get("ok", false), "Hosted endpoints must reject HTTP.")
	_assert(not Registry.validate_request_target(hosted, false, true).get("ok", false), "Android does not relax hosted transport policy.")

	var unsafe := hosted.duplicate(true)
	unsafe["base_url"] = "https://user:password@api.example.invalid"
	_assert(not Registry.validate_request_target(unsafe, false, false).get("ok", false), "Provider URLs must not contain embedded credentials.")
	unsafe["base_url"] = "https://api.example.invalid"
	unsafe["chat_endpoint"] = "/../../private"
	_assert(not Registry.validate_request_target(unsafe, false, false).get("ok", false), "Endpoint path traversal must be rejected.")

	if _failed:
		quit(1)
	else:
		print("PASS: AI provider catalog, HTTPS policy, local Ollama trust gate and Android loopback guard.")
		quit(0)

func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error(message)
