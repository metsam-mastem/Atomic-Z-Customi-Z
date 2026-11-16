# Free AI mode and multi-model provider support

## Intent
Atomic-Z-Customi-Z can optionally call external/local language models for assistant features. This is an optional integration; the motorcycle customization runtime remains usable without AI.

## Included adapter foundation
- `scripts/ai_model_registry.gd`: built-in provider descriptors and custom provider validation.
- `scripts/ai_chat_client.gd`: asynchronous HTTP chat adapter for Ollama's `/api/chat` and OpenAI-compatible `/v1/chat/completions` endpoints.
- Providers are extensible by adding a descriptor and choosing a compatible adapter kind. Provider APIs and free quotas may change.

## Free-first setup: Ollama
1. Install Ollama on a computer on the same Wi-Fi network as the Android device.
2. Pull a model, for example `ollama pull qwen2.5:3b` or another model suitable for the machine's memory.
3. Configure Ollama to listen on a LAN interface (not just loopback), with firewall access restricted to trusted devices.
4. In the app's provider descriptor, set the base URL to the host computer's LAN address and port 11434, e.g. `http://192.168.1.20:11434`.
5. The model ID must match the model installed in Ollama.

On Android, `127.0.0.1` refers to the phone itself, not the host computer. The default loopback URL is suitable only when Ollama is running on the same machine as the client. Exposing Ollama to a network can be unsafe; use a trusted LAN and do not port-forward it to the public internet.

## Adding providers/models
- Ollama models: set kind `ollama`, endpoint `/api/chat`, and the model ID installed on the Ollama host.
- OpenAI-compatible services: set kind `openai_compatible`, endpoint `/v1/chat/completions`, and the provider's base URL/model ID. Supply the API key via an environment variable name to the client; never commit raw secrets.
- Other providers: implement an adapter for their authentication, request schema, response parsing, and error behavior. A generic OpenAI-compatible endpoint will not automatically work with every provider.

## Cost and privacy
- Local Ollama inference can be free of per-token charges, but requires compatible hardware and consumes power/resources.
- Hosted services may offer free tiers, but free quotas, model availability, and terms are provider-controlled and may change. Some require an API key and/or billing details.
- Sending prompts to a hosted provider sends those prompts to that provider. Avoid secrets and personal data.
- API keys should be stored in a secure platform secret store or backend, not in source control, public JSON settings, or a client-distributed app. Environment variables are a development-safe baseline, not a robust secret vault for a distributed Android app.

## Current limitations / truthful status
This commit adds provider registry and HTTP adapter foundations, not a fully wired in-game AI panel. No Godot runtime test, Android export, or network/provider integration test has been run in this change. Next gate is connect the adapter to a dedicated AI settings/chat UI and add mocked HTTP tests.
