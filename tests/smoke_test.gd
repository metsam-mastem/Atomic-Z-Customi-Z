extends SceneTree

func _initialize() -> void:
	call_deferred("_run_smoke_test")

func _run_smoke_test() -> void:
	var packed_scene: PackedScene = load("res://scenes/main.tscn")
	if packed_scene == null:
		push_error("Main scene could not be loaded.")
		quit(1)
		return

	var scene := packed_scene.instantiate()
	root.add_child(scene)
	await process_frame

	var bike := scene.get_node_or_null("MotorcyclePlaceholder")
	if bike == null:
		push_error("Procedural motorcycle root is missing.")
		quit(1)
		return

	var neon := scene.get_node_or_null("NeonSkinOverlay")
	if neon == null:
		push_error("Godot neon skin overlay is not integrated into the garage.")
		quit(1)
		return
	if neon.call("get_segment_ids") != ["tail_underglow", "tank_accent", "lower_fairing"]:
		push_error("Garage neon overlay did not load the expected skin segments.")
		quit(1)
		return

	var tank := bike.get_node_or_null("fuel_tank") as Node3D
	if tank == null:
		push_error("Fuel tank part is missing.")
		quit(1)
		return

	var stock_position := tank.position
	bike.call("set_exploded", true)
	await process_frame
	if tank.position.is_equal_approx(stock_position):
		push_error("Exploded mode did not move the fuel tank.")
		quit(1)
		return

	bike.call("set_exploded", false)
	await process_frame
	if not tank.position.is_equal_approx(stock_position):
		push_error("Stock mode did not restore the fuel tank.")
		quit(1)
		return

	var tank_mesh := tank.get_node_or_null("VisualMesh") as MeshInstance3D
	if tank_mesh == null:
		push_error("Fuel tank mesh is missing.")
		quit(1)
		return
	var material := tank_mesh.material_override as StandardMaterial3D
	if material == null:
		push_error("Fuel tank material is missing.")
		quit(1)
		return

	var test_color := Color(0.1, 0.8, 0.3, 1.0)
	bike.call("set_body_color", test_color)
	if not material.albedo_color.is_equal_approx(test_color):
		push_error("Body color change did not reach the fuel tank material.")
		quit(1)
		return

	print("PASS: scene load, neon overlay integration, assembly explode/restore and body material update.")
	quit(0)
