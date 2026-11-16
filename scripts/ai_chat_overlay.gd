extends CanvasLayer

const AIChatClientScript = preload("res://scripts/ai_chat_client.gd")
const AIModelRegistryScript = preload("res://scripts/ai_model_registry.gd")

var _client: Node
var _panel: PanelContainer
var _backdrop: ColorRect
var _provider_selector: OptionButton
var _endpoint_input: LineEdit
var _model_input: LineEdit
var _key_env_input: LineEdit
var _allow_local_http: CheckBox
var _prompt_input: TextEdit
var _response_output: RichTextLabel
var _status_label: Label
var _send_button: Button
var _providers: Array[Dictionary] = []
var _conversation: Array[Dictionary] = []

func _ready() -> void:
	_client = AIChatClientScript.new()
	_client.name = "AIChatClient"
	add_child(_client)
	_providers = AIModelRegistryScript.get_builtin_providers()
	_build_panel()
	_panel.visible = false

func open_panel() -> void:
	_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	_backdrop.visible = true
	_panel.visible = true
	_panel.grab_focus()

func close_panel() -> void:
	_client.cancel_active_request()
	_panel.visible = false
	_backdrop.visible = false
	_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _build_panel() -> void:
	_backdrop = ColorRect.new()
	_backdrop.name = "AIBackdrop"
	_backdrop.color = Color(0.015, 0.025, 0.04, 0.78)
	_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_backdrop.visible = false
	add_child(_backdrop)

	_panel = PanelContainer.new()
	_panel.name = "AIPanel"
	_panel.anchor_left = 0.04
	_panel.anchor_top = 0.05
	_panel.anchor_right = 0.96
	_panel.anchor_bottom = 0.95
	_panel.offset_left = 0.0
	_panel.offset_top = 0.0
	_panel.offset_right = 0.0
	_panel.offset_bottom = 0.0
	add_child(_panel)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 8)
	_panel.add_child(layout)

	var header := HBoxContainer.new()
	layout.add_child(header)
	var title := Label.new()
	title.text = "OPTIONAL AI ASSISTANT  •  FREE-FIRST / MULTI-MODEL"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 16)
	header.add_child(title)
	var close_button := Button.new()
	close_button.text = "CLOSE"
	close_button.pressed.connect(close_panel)
	header.add_child(close_button)

	var explanation := Label.new()
	explanation.text = "Requests are sent to the endpoint you enter. Do not send passwords, personal data or confidential project files."
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(explanation)

	_provider_selector = OptionButton.new()
	for provider in _providers:
		_provider_selector.add_item(str(provider.get("name", provider.get("id", "Provider"))))
	_provider_selector.item_selected.connect(_on_provider_selected)
	layout.add_child(_provider_selector)

	_endpoint_input = LineEdit.new()
	_endpoint_input.placeholder_text = "Provider URL (e.g. http://192.168.1.20:11434)"
	_endpoint_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.add_child(_endpoint_input)

	_model_input = LineEdit.new()
	_model_input.placeholder_text = "Model ID (e.g. qwen2.5:3b)"
	layout.add_child(_model_input)

	_allow_local_http = CheckBox.new()
	_allow_local_http.text = "I trust this private Ollama LAN and allow unencrypted HTTP (no API key)"
	_allow_local_http.button_pressed = false
	layout.add_child(_allow_local_http)

	_key_env_input = LineEdit.new()
	_key_env_input.placeholder_text = "Desktop only: API-key environment-variable name (optional)"
	_key_env_input.visible = not OS.has_feature("android")
	_key_env_input.editable = not OS.has_feature("android")
	layout.add_child(_key_env_input)

	var android_note := Label.new()
	android_note.text = "Android: use the Ollama host's private LAN IP. Hosted API keys are disabled until secure credential storage is available."
	android_note.visible = OS.has_feature("android")
	android_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(android_note)

	_response_output = RichTextLabel.new()
	_response_output.bbcode_enabled = false
	_response_output.scroll_active = true
	_response_output.fit_content = false
	_response_output.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_response_output.text = "AI is optional. Your build remains local; only chat messages are sent to the endpoint you choose."
	layout.add_child(_response_output)

	_prompt_input = TextEdit.new()
	_prompt_input.custom_minimum_size = Vector2(0.0, 90.0)
	_prompt_input.placeholder_text = "Ask about styling, colors or design concepts..."
	layout.add_child(_prompt_input)

	var actions := HBoxContainer.new()
	layout.add_child(actions)
	_send_button = Button.new()
	_send_button.text = "SEND"
	_send_button.pressed.connect(_on_send_pressed)
	actions.add_child(_send_button)
	var clear := Button.new()
	clear.text = "CLEAR CHAT"
	clear.pressed.connect(_on_clear_chat)
	actions.add_child(clear)
	_status_label = Label.new()
	_status_label.text = "Ready • AI is optional"
	_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(_status_label)
	_on_provider_selected(0)

func _on_provider_selected(index: int) -> void:
	if index < 0 or index >= _providers.size():
		return
	var provider: Dictionary = _providers[index]
	var is_ollama := str(provider.get("kind", "")) == "ollama"
	_endpoint_input.text = ""
	_endpoint_input.placeholder_text = ("HTTPS Ollama endpoint (Android cleartext is disabled)" if OS.has_feature("android") else "Ollama private LAN URL (e.g. http://192.168.1.20:11434)") if is_ollama else "HTTPS provider URL"
	_model_input.text = ""
	_allow_local_http.visible = is_ollama and not OS.has_feature("android")
	_key_env_input.visible = not is_ollama and not OS.has_feature("android")
	_status_label.text = ("Android requires HTTPS for Ollama; cleartext LAN transport is disabled pending device verification." if OS.has_feature("android") else "Ollama is local-first; enter the server address and model ID.") if is_ollama else "Hosted providers must use HTTPS."

func _on_send_pressed() -> void:
	if _client.is_busy():
		_status_label.text = "A request is already running."
		return
	var prompt := _prompt_input.text.strip_edges()
	if prompt.is_empty():
		_status_label.text = "Enter a prompt first."
		return
	if prompt.length() > 8000:
		_status_label.text = "Prompt exceeds the 8,000 character limit."
		return
	var provider_index := _provider_selector.selected
	if provider_index < 0 or provider_index >= _providers.size():
		_status_label.text = "Select a provider."
		return
	var provider: Dictionary = _providers[provider_index].duplicate(true)
	provider["base_url"] = _endpoint_input.text.strip_edges()
	_conversation.append({"role": "user", "content": prompt})
	if _conversation.size() > 12:
		_conversation = _conversation.slice(_conversation.size() - 12)
	_prompt_input.editable = false
	_send_button.disabled = true
	_status_label.text = "Connecting..."
	_response_output.text = "Waiting for model response..."
	var result: Dictionary = await _client.chat(
		provider,
		_model_input.text.strip_edges(),
		_conversation,
		_key_env_input.text.strip_edges(),
		_allow_local_http.button_pressed
	)
	_prompt_input.editable = true
	_send_button.disabled = false
	if not is_inside_tree():
		return
	if result.get("ok", false):
		var answer := str(result.get("text", ""))
		_conversation.append({"role": "assistant", "content": answer})
		_response_output.text = answer
		_status_label.text = "Response received"
	else:
		_response_output.text = str(result.get("error", "Connection failed"))
		_status_label.text = "Connection failed"

func _on_clear_chat() -> void:
	_conversation.clear()
	_response_output.text = "Conversation cleared."
	_status_label.text = "Ready"
