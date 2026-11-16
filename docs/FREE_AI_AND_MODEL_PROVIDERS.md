# Optional AI Assistant — Provider Setup and Safety

**Status:** Optional in-garage capability; not required for core customization.  
**Runtime:** Godot 4 / GDScript.  
**Default:** no provider endpoint is preconfigured, no network request is made until the user opens the assistant and presses Send.

## Supported provider families

- **Ollama local / LAN:** free local inference with models installed on a computer running Ollama. Model IDs are entered manually (for example, `qwen2.5:3b`); hardware, memory and local network access are still required.
- **OpenAI-compatible HTTPS endpoint:** any endpoint that implements the expected `/v1/chat/completions` request/response contract. The user supplies the model ID and endpoint. Compatibility is not guaranteed for every vendor or model.

There is no paid dependency or bundled model. Hosted provider free tiers and quotas are controlled by the provider and may change; a generic compatible endpoint is not a promise of free service.

## Setup

1. Install and run Ollama on a trusted computer on your local network.
2. From Android, find the computer's private LAN IPv4 address; do not enter `127.0.0.1` or `localhost`.
3. On desktop, open **AI ASSIST**, choose Ollama, enter `http://127.0.0.1:11434` or a trusted private-LAN URL and a model ID that is already installed.
4. Enable the explicit private-LAN HTTP consent checkbox only when you trust that network. Cleartext traffic is not encrypted; never expose the Ollama port to the public internet.
5. On Android, provider endpoints must use HTTPS. Cleartext LAN HTTP is deliberately blocked until the Android manifest/network policy and target-device behavior are verified. If using a LAN Ollama server, expose it through a properly authenticated/trusted HTTPS endpoint.
6. For hosted OpenAI-compatible endpoints, enter an HTTPS URL. Desktop development builds may read an API key from an environment-variable name; the key itself is never persisted in project files, BuildDocument or preferences.
7. Android hosted API keys are deliberately disabled until a secure backend or platform credential design exists. Do not put a hosted key in the APK or user config.

## Data and privacy boundary

Chat messages and the selected model ID are sent to the endpoint the user enters. The build document, vehicle assets and local project files are not automatically uploaded. The user should not send passwords, personal data, proprietary files or other confidential content. The endpoint operator's privacy, retention, logging and pricing policies apply.

AI is opt-in and lazy-loaded inside the existing garage. If no endpoint is configured, the assistant does nothing. The motorcycle garage, save/load, paint, assembly and local customization remain available without AI or network access.

## Limits and failure handling

- Model IDs are manually entered; automatic model discovery and universal provider compatibility are not claimed.
- Conversations are limited to 12 messages, each at most 8,000 characters, with a 64 KiB request cap and 1 MiB response cap.
- Requests time out after the configured interval; redirects are disabled to avoid forwarding credentials to another host.
- Hosted providers require HTTPS. Cleartext HTTP is allowed only for an explicitly trusted private/local Ollama endpoint without credentials.
- Physical Android LAN, privacy review and hosted credential support remain separate release gates.

## Verification

Run:

```sh
godot --headless --editor --path . --quit
godot --headless --path . --script res://tests/ai_model_registry_test.gd
```

The registry test validates provider catalog and transport-policy gates without contacting a real provider. It is not a substitute for a live local Ollama test or Android device QA.
