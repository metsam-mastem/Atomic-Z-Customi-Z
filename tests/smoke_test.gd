extends SceneTree

const BuildDocumentScript = preload("res://scripts/build_document.gd")
const BikeAssemblyScript = preload("res://scripts/bike_assembly.gd")
const NeonSkinScript = preload("res://scripts/neon_skin.gd")

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

	var front_color_before: Color = bike.call("get_part_color", "front_fairing")
	var isolated_paint := Color("#2A7BDA")
	if not bike.call("set_part_color", "fuel_tank", isolated_paint):
		push_error("A known part must accept an isolated paint edit.")
		quit(1)
		return
	var isolated_tank_color: Color = bike.call("get_part_color", "fuel_tank")
	if not isolated_tank_color.is_equal_approx(isolated_paint):
		push_error("Selected part must receive the requested paint color.")
		quit(1)
		return
	var isolated_front_color: Color = bike.call("get_part_color", "front_fairing")
	if not isolated_front_color.is_equal_approx(front_color_before):
		push_error("Painting one part must not recolor another part.")
		quit(1)
		return

	var project_color := Color(0.2, 0.4, 0.9, 1.0)
	scene.call("_on_body_color_changed", project_color)
	scene.call("_on_neon_primary_changed", Color("#123456"))
	scene.call("_on_glow_changed", 0.55)
	scene.call("_on_neon_toggled", false)
	bike.call("set_exploded", true)
	var saved_exploded_tank_position: Vector3 = tank.position
	var summary_label := scene.find_child("BuildSummaryLabel", true, false) as Label
	if summary_label == null or not summary_label.text.contains("BUILD  /") or not summary_label.text.contains("fuel tank"):
		push_error("Garage HUD must display the active BuildDocument and selected part.")
		quit(1)
		return
	var document: Dictionary = scene.call("get_build_document_snapshot")
	if document.get("schema_version") != 1:
		push_error("Garage must expose the canonical BuildDocument.")
		quit(1)
		return
	if document.get("assembly", {}).get("parts", []).size() < 10:
		push_error("Assembly parts must be represented in the shared BuildDocument.")
		quit(1)
		return
	if document.get("customization", {}).get("materials", []).is_empty():
		push_error("Body paint edits must update the shared BuildDocument.")
		quit(1)
		return
	var fuel_paint_record_found := false
	for material_record in document.get("customization", {}).get("materials", []):
		if material_record is Dictionary and str(material_record.get("material_id", "")) == "paint:fuel_tank":
			fuel_paint_record_found = material_record.get("target_part_ids", []) == ["fuel_tank"]
	if not fuel_paint_record_found:
		push_error("BuildDocument must persist the selected part's stable paint target.")
		quit(1)
		return
	if document.get("customization", {}).get("palette", {}).get("primary") != "#123456":
		push_error("Neon palette edits must update the shared BuildDocument.")
		quit(1)
		return
	if not is_equal_approx(float(document.get("render", {}).get("glow_intensity", -1.0)), 0.55):
		push_error("Glow edits must update the shared BuildDocument.")
		quit(1)
		return
	if not scene.call("save_project"):
		push_error("Unified BuildDocument must save successfully.")
		quit(1)
		return
	if not summary_label.text.contains("REVISION  /  2"):
		push_error("HUD must reflect the persisted BuildDocument revision after save.")
		quit(1)
		return
	var saved := FileAccess.open("user://atomic_z_build.json", FileAccess.READ)
	if saved == null:
		push_error("Saved BuildDocument file is missing.")
		quit(1)
		return
	var restored: Dictionary = BuildDocumentScript.from_json(saved.get_as_text())
	saved.close()
	if restored.is_empty() or restored.get("customization", {}).get("palette", {}).get("primary") != "#123456":
		push_error("Saved BuildDocument must preserve shared customization state.")
		quit(1)
		return
	if bool(restored.get("render", {}).get("neon_enabled", true)):
		push_error("Saved neon visibility must be stored in the canonical BuildDocument.")
		quit(1)
		return
	if str(restored.get("assembly", {}).get("mode", "")) != "exploded":
		push_error("Saved assembly mode must be stored in the canonical BuildDocument.")
		quit(1)
		return

	var restored_bike := BikeAssemblyScript.new()
	restored_bike.configure_build_document(restored)
	root.add_child(restored_bike)
	await process_frame
	var restored_tank_color: Color = restored_bike.get_part_color("fuel_tank")
	var restored_front_color: Color = restored_bike.get_part_color("front_fairing")
	var restored_tank_position: Vector3 = restored_bike.get_node("fuel_tank").position
	var expected_project_color := Color.from_string("#" + project_color.to_html(false).to_upper(), Color.WHITE)
	var expected_test_color := Color.from_string("#" + test_color.to_html(false).to_upper(), Color.WHITE)
	if not restored_tank_color.is_equal_approx(expected_project_color):
		push_error("Saved selected-part paint must be restored into the 3D assembly.")
		quit(1)
		return
	if not restored_front_color.is_equal_approx(expected_test_color):
		push_error("Saved paint for another part must remain independent after reload.")
		quit(1)
		return
	if not restored_tank_position.is_equal_approx(saved_exploded_tank_position):
		push_error("Saved Stock/Exploded mode must restore the assembly transforms.")
		quit(1)
		return

	var restored_neon := NeonSkinScript.new()
	restored_neon.configure_build_document(restored)
	root.add_child(restored_neon)
	await process_frame
	for neon_visual in restored_neon.get_children():
		if neon_visual.visible:
			push_error("Saved disabled neon state must be restored into the runtime visuals.")
			quit(1)
			return

	for path in ["user://atomic_z_build.json", "user://atomic_z_build.json.tmp", "user://atomic_z_build.json.bak"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

	print("PASS: part-isolated paint, canonical state, neon visibility and BuildDocument save/reload recovery.")

	quit(0)
