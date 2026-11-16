extends RefCounted
class_name AIModelRegistry

## Optional provider metadata. Model IDs are intentionally user-selected rather than assumed.
const BUILTIN_PROVIDERS := [
	{
		"id": "ollama",
		"name": "Ollama (local / LAN)",
		"kind": "ollama",
		"base_url": "",
		"free": true,
		"requires_api_key": false,
		"chat_endpoint": "/api/chat"
	},
	{
		"id": "openai_compatible",
		"name": "OpenAI-compatible endpoint",
		"kind": "openai_compatible",
		"base_url": "",
		"free": false,
		"requires_api_key": false,
		"chat_endpoint": "/v1/chat/completions"
	}
]

static func get_builtin_providers() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for provider in BUILTIN_PROVIDERS:
		result.append(provider.duplicate(true))
	return result

static func validate_provider(provider: Dictionary) -> Dictionary:
	var provider_id := str(provider.get("id", "")).strip_edges()
	var name := str(provider.get("name", "")).strip_edges()
	var kind := str(provider.get("kind", "")).strip_edges()
	var endpoint := str(provider.get("chat_endpoint", "")).strip_edges()
	if provider_id.is_empty() or name.is_empty():
		return {"ok": false, "error": "Provider ID and display name are required."}
	if kind not in ["ollama", "openai_compatible"]:
		return {"ok": false, "error": "Supported provider types are Ollama and OpenAI-compatible."}
	if endpoint.is_empty() or not endpoint.begins_with("/") or endpoint.contains("..") or endpoint.contains("?") or endpoint.contains("#"):
		return {"ok": false, "error": "Chat endpoint must be a safe relative path beginning with /."}
	return {"ok": true, "provider": provider.duplicate(true)}

## Enforces transport and host restrictions before any request is constructed.
## Cleartext is allowed only after an explicit opt-in for a local Ollama endpoint.
static func validate_request_target(provider: Dictionary, allow_local_http: bool, is_android: bool, has_api_key: bool = false) -> Dictionary:
	var provider_result := validate_provider(provider)
	if not provider_result.get("ok", false):
		return provider_result

	var kind := str(provider.get("kind", ""))
	var base_url := normalize_base_url(str(provider.get("base_url", "")))
	if base_url.is_empty() or base_url.contains(" ") or base_url.contains("@") or base_url.contains("?") or base_url.contains("#"):
		return {"ok": false, "error": "Enter a valid provider base URL without credentials, query strings or fragments."}
	if not (base_url.begins_with("https://") or base_url.begins_with("http://")):
		return {"ok": false, "error": "Provider URL must use HTTPS."}

	var scheme := base_url.get_slice("://", 0).to_lower()
	var remainder := base_url.get_slice("://", 1)
	var authority := remainder.get_slice("/", 0)
	if authority.is_empty() or authority == ":":
		return {"ok": false, "error": "Provider URL must include a host."}
	var host := _extract_host(authority)
	if host.is_empty():
		return {"ok": false, "error": "Provider URL host is invalid."}

	if kind == "openai_compatible" and scheme != "https":
		return {"ok": false, "error": "Hosted OpenAI-compatible endpoints require HTTPS."}
	if has_api_key and scheme != "https":
		return {"ok": false, "error": "Credentials must never be sent over cleartext HTTP."}
	if kind == "ollama" and scheme == "http":
		if is_android:
			return {"ok": false, "error": "Android cleartext HTTP is disabled until native network policy and device QA are verified."}
		if not allow_local_http:
			return {"ok": false, "error": "Allow local HTTP explicitly before connecting to Ollama."}
		if not _is_local_or_private_host(host):
			return {"ok": false, "error": "Cleartext Ollama is limited to localhost or a private LAN IP."}
	if is_android and _is_loopback_host(host):
		return {"ok": false, "error": "On Android, 127.0.0.1 is the phone itself. Enter the Ollama host's LAN IP."}
	return {"ok": true, "base_url": base_url, "host": host, "scheme": scheme}

static func normalize_base_url(base_url: String) -> String:
	return base_url.strip_edges().trim_suffix("/")

static func _extract_host(authority: String) -> String:
	if authority.begins_with("["):
		var closing := authority.find("]")
		return authority.substr(1, closing - 1).to_lower() if closing > 1 else ""
	return authority.get_slice(":", 0).to_lower()

static func _is_loopback_host(host: String) -> bool:
	return host == "localhost" or host == "::1" or host.begins_with("127.")

static func _is_local_or_private_host(host: String) -> bool:
	if _is_loopback_host(host):
		return true
	var octets := host.split(".")
	if octets.size() != 4:
		return false
	for octet in octets:
		if not octet.is_valid_int():
			return false
		var value := int(octet)
		if value < 0 or value > 255:
			return false
	var first := int(octets[0])
	var second := int(octets[1])
	return first == 10 or first == 192 and second == 168 or first == 172 and second >= 16 and second <= 31 or first == 169 and second == 254
