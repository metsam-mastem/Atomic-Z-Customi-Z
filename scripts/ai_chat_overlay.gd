extends CanvasLayer

const AIChatClientScript = preload("res://scripts/ai_chat_client.gd")

var _client: Node
var _panel: PanelContainer
var _provider_selector: OptionButton
var _endpoint_input: LineEdit
var _model_input: LineEdit
var _key_env_input: LineEdit
var _prompt_input: TextEdit
var _response_output: RichTextLabel
var _status_label: Label
var _conversation: Array[Dictionary] = []

func _ready() -> void:
	_client = AIChatClientScript.new()
	_client.name = "AIChatClient"
	add_child(_client)
	_build_overlay()

func _build_overlay() -> void:
	var toggle := Button.new()
	toggle.text = "FREE AI / MODELS"
	toggle.position = Vector2(-210.0, 18.0)
	toggle.anchor_left = 1.0
	toggle.anchor_right = 1.0
	toggle.custom_minimum_size = Vector2(190.0, 42.0)
	toggle.pressed.connect(_toggle_panel)
	add_child(toggle)

	_panel = PanelContainer.new()
	_panel.anchor_left = 0.38
	_panel.anchor_top = 0.12
	_panel.anchor_right = 0.98
	_panel.anchor_bottom = 0.88
	_panel.offset_left = 0.0
	_panel.offset_top = 0.0
	_panel.offset_right = 0.0
	_panel.offset_bottom = 0.0
	_panel.visible = false
	add_child(_panel)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 8)
	_panel.add_child(layout)

	var title := Label.new()
	title.text = "OPTIONAL AI CHAT  •  FREE-FIRST / MULTI-MODEL"
	title.add_theme_font_size_override("font_size", 18)
	layout.add_child(title)

	_provider_selector = OptionButton.new()
	_provider_selector.add_item("Ollama Local (no per-token fee)", 0)
	_provider_selector.add_item("OpenAI-compatible hosted API", 1)
	_provider_selector.item_selected.connect(_on_provider_selected)
	layout.add_child(_provider_selector)

	_endpoint_input = LineEdit.new()
	_endpoint_input.text = "http://127.0.0.1:11434"
	_endpoint_input.placeholder_text = "Provider base URL"
	_endpoint_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.add_child(_endpoint_input)

	_model_input = LineEdit.new()
	_model_input.text = "qwen2.5:3b"
	_model_input.placeholder_text = "Model ID (must exist at provider)"
	layout.add_child(_model_input)

	_key_env_input = LineEdit.new()
	_key_env_input.placeholder_text = "API key environment variable name (hosted only)"
	layout.add_child(_key_env_input)

	_response_output = RichTextLabel.new()
	_response_output.bbcode_enabled = true
	_response_output.scroll_active = true
	_response_output.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_response_output.text = "[color=#aab8c8]Chat response appears here. For Android, use your host computer's LAN IP, not 127.0.0.1.[/color]"
	layout.add_child(_response_output)

	_prompt_input = TextEdit.new()
	_prompt_input.custom_minimum_size = Vector2(0.0, 78.0)
	_prompt_input.placeholder_text = "Ask about styling, colors, design concepts..."
	layout.add_child(_prompt_input)

	var actions := HBoxContainer.new()
	layout.add_child(actions)
	var send := Button.new()
	send.text = "SEND"
	send.pressed.connect(_on_send_pressed)
	actions.add_child(send)
	var clear := Button.new()
	clear.text = "CLEAR CHAT"
	clear.pressed.connect(_on_clear_chat)
	actions.add_child(clear)
	_status_label = Label.new()
	_status_label.text = "Ready • AI is optional"
	actions.add_child(_status_label)

func _toggle_panel() -> void:
	_panel.visible = not _panel.visible

func _on_provider_selected(index: int) -> void:
	if index == 0:
		_endpoint_input.text = "http://127.0.0.1:11434"
		_model_input.text = "qwen2.5:3b"
		_key_env_input.text = ""
	else:
		_endpoint_input.text = "https://your-provider.example"
		_model_input.text = ""
		_key_env_input.text = "ATOMIC_Z_AI_API_KEY"

func _on_send_pressed() -> void:
	var prompt := _prompt_input.text.strip_edges()
	if prompt.is_empty():
		_status_label.text = "Enter a prompt first."
		return
	var provider_index := _provider_selector.selected
	var provider := {
		"kind": "ollama" if provider_index == 0 else "openai_compatible",
		"base_url": _endpoint_input.text.strip_edges(),
		"chat_endpoint": "/api/chat" if provider_index == 0 else "/v1/chat/completions"
	}
	_conversation.append({"role": "user", "content": prompt})
	if _conversation.size() > 12:
		_conversation = _conversation.slice(_conversation.size() - 12)
	_prompt_input.editable = false
	_status_label.text = "Connecting..."
	_response_output.text = "[color=#aab8c8]Waiting for model response...[/color]"
	var result: Dictionary = await _client.chat(provider, _model_input.text.strip_edges(), _conversation, _key_env_input.text.strip_edges())
	_prompt_input.editable = true
	if result.get("ok", false):
		var answer := str(result.get("text", ""))
		_conversation.append({"role": "assistant", "content": answer})
		_response_output.text = answer
		_status_label.text = "Response received"
	else:
		_response_output.text = "[color=#ff8585]" + str(result.get("error", "Unknown error")).replace("[", "\\[") + "[/color]"
		_status_label.text = "Connection failed"

func _on_clear_chat() -> void:
	_conversation.clear()
	_response_output.text = "[color=#aab8c8]Conversation cleared.[/color]"
	_status_label.text = "Ready"
