extends SceneTree

const BuildDocumentScript = preload("res://scripts/build_document.gd")

func _initialize() -> void:
	call_deferred("_run_smoke_test")

func _run_smoke_test() -> void:
	_remove_file_if_exists("user://atomic_z_build.json")
	_remove_file_if_exists("user://atomic_z_build.json.tmp")
	_remove_file_if_exists("user://atomic_z_build.json.bak")
	_remove_file_if_exists("user://atomic_z_build.json.recovery.tmp")
	var stale_backup_directory := ProjectSettings.globalize_path("user://atomic_z_build.json.bak")
	if DirAccess.dir_exists_absolute(stale_backup_directory):
		DirAccess.remove_absolute(stale_backup_directory)

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

	var project_color := Color(0.2, 0.4, 0.9, 1.0)
	scene.call("_on_body_color_changed", project_color)
	scene.call("_on_neon_primary_changed", Color("#123456"))
	scene.call("_on_glow_changed", 0.55)
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
	var saved := FileAccess.open("user://atomic_z_build.json", FileAccess.READ)
	if saved == null:
		push_error("Saved BuildDocument file is missing.")
		quit(1)
		return
	var restored: Dictionary = BuildDocumentScript.from_json(saved.get_as_text())
	saved.close()

	var revision_before_failed_save := int(scene.call("get_build_document_snapshot").get("revision", 0))
	var backup_directory := ProjectSettings.globalize_path("user://atomic_z_build.json.bak")
	if DirAccess.make_dir_absolute(backup_directory) != OK:
		push_error("A backup-path conflict fixture must be created.")
		quit(1)
		return
	if scene.call("save_project"):
		push_error("A save must fail when the backup destination cannot be rotated.")
		quit(1)
		return
	var revision_after_failed_save := int(scene.call("get_build_document_snapshot").get("revision", 0))
	if revision_after_failed_save != revision_before_failed_save:
		push_error("A failed save must not increment the in-memory BuildDocument revision.")
		quit(1)
		return
	if DirAccess.remove_absolute(backup_directory) != OK:
		push_error("The backup-path conflict fixture must be removed.")
		quit(1)
		return
	var preserved_primary := FileAccess.open("user://atomic_z_build.json", FileAccess.READ)
	if preserved_primary == null:
		push_error("A failed save must preserve the previous primary BuildDocument.")
		quit(1)
		return
	preserved_primary.close()
	if restored.is_empty() or restored.get("customization", {}).get("palette", {}).get("primary") != "#123456":
		push_error("Saved BuildDocument must preserve shared customization state.")
		quit(1)
		return
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://atomic_z_build.json"))

	print("PASS: scene load, neon overlay integration, assembly explode/restore and body material update.")
	quit(0)
