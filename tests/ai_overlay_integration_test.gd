extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed_scene := load("res://scenes/main.tscn") as PackedScene
	if packed_scene == null:
		push_error("Garage scene must load for the optional AI integration test.")
		quit(1)
		return

	var garage := packed_scene.instantiate()
	root.add_child(garage)
	await process_frame

	var ai_button := garage.find_child("AIAssistantButton", true, false) as Button
	if ai_button == null:
		push_error("The integrated garage must expose an explicit AI ASSIST action.")
		quit(1)
		return
	if garage.get_node_or_null("OptionalAIAssistant") != null:
		push_error("AI assistant must remain unloaded until the user invokes it.")
		quit(1)
		return

	garage.call("_open_ai_assistant")
	await process_frame
	var overlay := garage.get_node_or_null("OptionalAIAssistant") as CanvasLayer
	if overlay == null:
		push_error("The AI assistant must load into the existing garage lifecycle.")
		quit(1)
		return
	var panel := overlay.get_node_or_null("AIPanel") as PanelContainer
	if panel == null or not panel.visible:
		push_error("Invoking AI ASSIST must open the assistant panel.")
		quit(1)
		return

	overlay.call("close_panel")
	if panel.visible:
		push_error("The optional assistant must close without leaving the panel visible.")
		quit(1)
		return

	print("PASS: AI assistant is user-invoked, lazy-loaded and hosted inside the existing garage scene.")
	quit(0)
