extends RefCounted
class_name AIModelRegistry

## Free-first provider catalog. Cloud services may impose changing free quotas.
const BUILTIN_PROVIDERS := [
	{
		"id": "ollama",
		"name": "Ollama (local)",
		"kind": "ollama",
		"base_url": "http://127.0.0.1:11434",
		"free": true,
		"requires_api_key": false,
		"models_endpoint": "/api/tags",
		"chat_endpoint": "/api/chat"
	},
	{
		"id": "openai_compatible",
		"name": "OpenAI-compatible API",
		"kind": "openai_compatible",
		"base_url": "",
		"free": false,
		"requires_api_key": true,
		"models_endpoint": "",
		"chat_endpoint": "/v1/chat/completions"
	}
]

static func get_builtin_providers() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for provider in BUILTIN_PROVIDERS:
		result.append(provider.duplicate(true))
	return result

static func validate_custom_provider(provider: Dictionary) -> Dictionary:
	var provider_id := str(provider.get("id", "")).strip_edges()
	var name := str(provider.get("name", "")).strip_edges()
	var kind := str(provider.get("kind", "")).strip_edges()
	var base_url := str(provider.get("base_url", "")).strip_edges()
	var chat_endpoint := str(provider.get("chat_endpoint", "")).strip_edges()
	if provider_id.is_empty() or name.is_empty():
		return {"ok": false, "error": "Provider id and name are required."}
	if kind not in ["ollama", "openai_compatible"]:
		return {"ok": false, "error": "Supported kinds: ollama, openai_compatible."}
	if not (base_url.begins_with("http://") or base_url.begins_with("https://")):
		return {"ok": false, "error": "base_url must use HTTP or HTTPS."}
	if chat_endpoint.is_empty() or not chat_endpoint.begins_with("/"):
		return {"ok": false, "error": "chat_endpoint must be a relative path beginning with /."}
	return {"ok": true, "provider": provider.duplicate(true)}

static func normalize_base_url(base_url: String) -> String:
	return base_url.strip_edges().trim_suffix("/")
