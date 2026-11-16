extends SceneTree

const BuildDocumentScript = preload("res://scripts/build_document.gd")
const BuildDocumentStoreScript = preload("res://scripts/build_document_store.gd")
const GlbSurfaceCatalogScript = preload("res://scripts/glb_surface_catalog.gd")
const BikeAssemblyScript = preload("res://scripts/bike_assembly.gd")

const FIXTURE_PATH := "user://atomic_z_glb_runtime_fixture.glb"
const SAVE_PATH := "user://atomic_z_glb_runtime_build.json"
const MAIN_SAVE_PATH := "user://atomic_z_build.json"
const FIXTURE_BASE64 := "Z2xURgIAAABcBwAA8AUAAEpTT057ImFzc2V0Ijp7InZlcnNpb24iOiIyLjAiLCJnZW5lcmF0b3IiOiJBdG9taWMgWiBzeW50aGV0aWMgR0xCIHJ1bnRpbWUgdGVzdCBmaXh0dXJlIn0sInNjZW5lIjowLCJzY2VuZXMiOlt7Im5hbWUiOiJBdG9taWNGaXh0dXJlVmVoaWNsZSIsIm5vZGVzIjpbMF19XSwibm9kZXMiOlt7Im5hbWUiOiJBdG9taWNGaXh0dXJlVmVoaWNsZSIsImNoaWxkcmVuIjpbMSwyXX0seyJuYW1lIjoiQm9keVBhbmVsIiwibWVzaCI6MH0seyJuYW1lIjoiRnJvbnRXaGVlbFJpbSIsIm1lc2giOjF9XSwibWVzaGVzIjpbeyJuYW1lIjoiQm9keVBhbmVsTWVzaCIsInByaW1pdGl2ZXMiOlt7ImF0dHJpYnV0ZXMiOnsiUE9TSVRJT04iOjB9LCJpbmRpY2VzIjoxLCJtYXRlcmlhbCI6MH1dfSx7Im5hbWUiOiJGcm9udFdoZWVsUmltTWVzaCIsInByaW1pdGl2ZXMiOlt7ImF0dHJpYnV0ZXMiOnsiUE9TSVRJT04iOjJ9LCJpbmRpY2VzIjozLCJtYXRlcmlhbCI6MX1dfV0sIm1hdGVyaWFscyI6W3sibmFtZSI6IkZpeHR1cmVCb2R5UGFpbnQiLCJwYnJNZXRhbGxpY1JvdWdobmVzcyI6eyJiYXNlQ29sb3JGYWN0b3IiOlswLjIsMC4zNSwwLjY1LDEuMF0sIm1ldGFsbGljRmFjdG9yIjowLjQ1LCJyb3VnaG5lc3NGYWN0b3IiOjAuMzh9fSx7Im5hbWUiOiJGaXh0dXJlUmltTWV0YWwiLCJwYnJNZXRhbGxpY1JvdWdobmVzcyI6eyJiYXNlQ29sb3JGYWN0b3IiOlswLjY1LDAuNjgsMC43MiwxLjBdLCJtZXRhbGxpY0ZhY3RvciI6MC45LCJyb3VnaG5lc3NGYWN0b3IiOjAuMjJ9fV0sImJ1ZmZlcnMiOlt7ImJ5dGVMZW5ndGgiOjMzNn1dLCJidWZmZXJWaWV3cyI6W3siYnVmZmVyIjowLCJieXRlT2Zmc2V0IjowLCJieXRlTGVuZ3RoIjo5NiwidGFyZ2V0IjozNDk2Mn0seyJidWZmZXIiOjAsImJ5dGVPZmZzZXQiOjk2LCJieXRlTGVuZ3RoIjo3MiwidGFyZ2V0IjozNDk2M30seyJidWZmZXIiOjAsImJ5dGVPZmZzZXQiOjE2OCwiYnl0ZUxlbmd0aCI6OTYsInRhcmdldCI6MzQ5NjJ9LHsiYnVmZmVyIjowLCJieXRlT2Zmc2V0IjoyNjQsImJ5dGVMZW5ndGgiOjcyLCJ0YXJnZXQiOjM0OTYzfV0sImFjY2Vzc29ycyI6W3siYnVmZmVyVmlldyI6MCwiY29tcG9uZW50VHlwZSI6NTEyNiwiY291bnQiOjgsInR5cGUiOiJWRUMzIiwibWluIjpbLTAuNzUsMC4xNzUsLTAuMTc1XSwibWF4IjpbMC43NSwwLjUyNDk5OTk5OTk5OTk5OTksMC4xNzVdfSx7ImJ1ZmZlclZpZXciOjEsImNvbXBvbmVudFR5cGUiOjUxMjMsImNvdW50IjozNiwidHlwZSI6IlNDQUxBUiIsIm1pbiI6WzBdLCJtYXgiOls3XX0seyJidWZmZXJWaWV3IjoyLCJjb21wb25lbnRUeXBlIjo1MTI2LCJjb3VudCI6OCwidHlwZSI6IlZFQzMiLCJtaW4iOlswLjcyNTAwMDAwMDAwMDAwMDEsLTAuMzg3NDk5OTk5OTk5OTk5OTYsMC4yMDUwMDAwMDAwMDAwMDAwMl0sIm1heCI6WzEuMDc1LC0wLjIxMjUsMC4yOTVdfSx7ImJ1ZmZlclZpZXciOjMsImNvbXBvbmVudFR5cGUiOjUxMjMsImNvdW50IjozNiwidHlwZSI6IlNDQUxBUiIsIm1pbiI6WzBdLCJtYXgiOls3XX1dfVABAABCSU4AAABAvzMzMz4zMzO+AABAPzMzMz4zMzO+AABAP2ZmBj8zMzO+AABAv2ZmBj8zMzO+AABAvzMzMz4zMzM+AABAPzMzMz4zMzM+AABAP2ZmBj8zMzM+AABAv2ZmBj8zMzM+AAACAAEAAAADAAIABAAFAAYABAAGAAcAAAABAAUAAAAFAAQAAwAHAAYAAwAGAAIAAAAEAAcAAAAHAAMAAQACAAYAAQAGAAUAmpk5P2Zmxr6F61E+mpmJP2Zmxr6F61E+mpmJP5qZWb6F61E+mpk5P5qZWb6F61E+mpk5P2Zmxr49Cpc+mpmJP2Zmxr49Cpc+mpmJP5qZWb49Cpc+mpk5P5qZWb49Cpc+AAACAAEAAAADAAIABAAFAAYABAAGAAcAAAABAAUAAAAFAAQAAwAHAAYAAwAGAAIAAAAEAAcAAAAHAAMAAQACAAYAAQAGAAUA"

var _failed := false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_remove_if_exists(FIXTURE_PATH)
	_remove_if_exists(SAVE_PATH)
	_remove_if_exists(SAVE_PATH + ".tmp")
	_remove_if_exists(SAVE_PATH + ".bak")
	_remove_if_exists(MAIN_SAVE_PATH)
	_remove_if_exists(MAIN_SAVE_PATH + ".tmp")
	_remove_if_exists(MAIN_SAVE_PATH + ".bak")

	var fixture_file := FileAccess.open(FIXTURE_PATH, FileAccess.WRITE)
	_assert(fixture_file != null, "Synthetic GLB fixture must be writable.")
	if fixture_file == null:
		quit(1)
		return
	fixture_file.store_buffer(Marshalls.base64_to_raw(FIXTURE_BASE64))
	fixture_file.close()

	var gltf_document := GLTFDocument.new()
	var gltf_state := GLTFState.new()
	var import_error: Error = gltf_document.append_from_file(FIXTURE_PATH, gltf_state)
	_assert(import_error == OK, "Godot GLTFDocument must parse the synthetic binary GLB.")
	if import_error != OK:
		_cleanup()
		quit(1)
		return
	var source_scene := gltf_document.generate_scene(gltf_state)
	_assert(source_scene is Node3D, "Synthetic GLB must generate a Node3D scene.")
	if not (source_scene is Node3D):
		_cleanup()
		quit(1)
		return

	var inventory: Dictionary = GlbSurfaceCatalogScript.inspect_scene(source_scene)
	_assert(inventory.get("ok", false), "GLB surface inventory must succeed.")
	var surfaces: Array = inventory.get("surfaces", [])
	_assert(surfaces.size() == 2, "Fixture GLB must expose two independently editable surfaces.")
	if surfaces.size() != 2:
		source_scene.free()
		_cleanup()
		quit(1)
		return

	source_scene.free()

	var document := BuildDocumentScript.create_default("fixture-bike", "Synthetic GLB Test Bike")
	document["asset"]["uri"] = FIXTURE_PATH
	document["asset"]["sha256"] = FileAccess.get_sha256(FIXTURE_PATH)
	document["asset"]["license"] = "CC0-1.0"
	document["asset"]["source"] = "Atomic-Z-Customi-Z synthetic GLB test fixture"
	document["asset"]["validation_status"] = "test_fixture"
	_assert(BuildDocumentScript.validate(document).get("ok", false), "Pinned local GLB document with an empty catalog must satisfy the canonical schema.")

	var bike := BikeAssemblyScript.new()
	bike.name = "ImportedFixtureBike"
	bike.configure_build_document(document)
	root.add_child(bike)
	await process_frame
	_assert(bike.is_imported_model(), "A valid local GLB with matching SHA must replace procedural geometry and generate its catalog.")
	_assert(bike.get_part_ids() == ["body_panel", "front_wheel_rim"], "Imported mesh names must become stable part IDs for the existing garage selector.")
	_assert(document.get("asset", {}).get("surface_catalog", []).size() == 2, "The runtime must auto-create and persist a stable surface catalog in BuildDocument.")
	_assert(not bike.supports_exploded_view(), "Exploded mode must be unavailable until verified part pivots/offsets exist.")

	var body_before := bike.get_part_color("body_panel")
	var rim_before := bike.get_part_color("front_wheel_rim")
	_assert(body_before.is_equal_approx(Color(0.4845292, 0.6262097, 0.8266571, 1.0)), "Imported body PBR base color must load.")
	_assert(rim_before.is_equal_approx(Color(0.8266571, 0.8433892, 0.865042, 1.0)), "Imported rim PBR base color must load.")
	var body_color := Color("#AABBCC")
	var rim_color := Color("#B58A32")
	_assert(bike.set_part_color("body_panel", body_color), "Imported body panel must be independently paintable.")
	_assert(bike.set_part_color("front_wheel_rim", rim_color), "Imported front rim must be independently paintable.")
	_assert(bike.get_part_color("body_panel").is_equal_approx(body_color), "Imported body color must update in the rendered scene.")
	_assert(bike.get_part_color("front_wheel_rim").is_equal_approx(rim_color), "Imported rim color must update in the rendered scene.")
	_assert(not bike.get_part_color("body_panel").is_equal_approx(bike.get_part_color("front_wheel_rim")), "Independent surface edits must not alias each other.")

	var body_surface_id := "body_panel.surface_0"
	var edited_body_material := bike.call("_get_imported_surface_material", body_surface_id) as StandardMaterial3D
	_assert(edited_body_material != null, "Imported surface edits must create an owned StandardMaterial3D override.")
	if edited_body_material != null:
		_assert(is_equal_approx(edited_body_material.metallic, 0.45), "Imported body metallic value must survive an albedo edit.")
		_assert(is_equal_approx(edited_body_material.roughness, 0.38), "Imported body roughness must survive an albedo edit.")

	_assert(BuildDocumentStoreScript.save_document(document, SAVE_PATH), "Imported surface edits must save through BuildDocumentStore.")
	var restored_document: Dictionary = BuildDocumentStoreScript.load_document(SAVE_PATH)
	_assert(not restored_document.is_empty(), "Saved imported BuildDocument must reload and validate.")
	var restored_bike := BikeAssemblyScript.new()
	restored_bike.configure_build_document(restored_document)
	root.add_child(restored_bike)
	await process_frame
	_assert(restored_bike.is_imported_model(), "A saved GLB reference and catalog must restore the imported model.")
	_assert(restored_bike.get_part_color("body_panel").is_equal_approx(body_color), "Saved imported body paint must be reapplied on reopen.")
	_assert(restored_bike.get_part_color("front_wheel_rim").is_equal_approx(rim_color), "Saved imported rim paint must be reapplied on reopen.")

	_assert(BuildDocumentStoreScript.save_document(restored_document, MAIN_SAVE_PATH), "Imported GLB BuildDocument must be staged for the integrated garage UI test.")
	var main_packed: PackedScene = load("res://scenes/main.tscn")
	_assert(main_packed != null, "Integrated garage scene must be loadable for the GLB UI test.")
	if main_packed != null:
		var main_scene := main_packed.instantiate()
		root.add_child(main_scene)
		await process_frame
		var main_bike = main_scene.get_node_or_null("MotorcyclePlaceholder")
		_assert(main_bike != null and main_bike.is_imported_model(), "The existing garage scene must boot directly into the persisted imported GLB.")
		var assembly_button := main_scene.find_child("AssemblyModeButton", true, false) as Button
		var neon_button := main_scene.find_child("NeonToggleButton", true, false) as Button
		var neon_primary := main_scene.find_child("NeonPrimaryPicker", true, false) as ColorPickerButton
		var glow_slider := main_scene.find_child("NeonGlowSlider", true, false) as HSlider
		var summary := main_scene.find_child("BuildSummaryLabel", true, false) as Label
		var overlay := main_scene.get_node_or_null("NeonSkinOverlay") as Node3D
		_assert(assembly_button != null and assembly_button.disabled, "The integrated UI must disable Exploded mode until part pivots are verified.")
		_assert(neon_button != null and neon_button.disabled, "The integrated UI must disable unverified Neon paths for an imported GLB.")
		_assert(neon_primary != null and neon_primary.disabled, "Imported GLB mode must disable Neon palette editing until UV mapping is verified.")
		_assert(glow_slider != null and not glow_slider.editable, "Imported GLB mode must disable the unverified Neon glow control.")
		_assert(overlay != null and not overlay.visible, "Legacy screen-space Neon overlays must not float over an imported GLB.")
		_assert(summary != null and summary.text.contains("IMPORTED GLB") and summary.text.contains("DISABLED"), "HUD must identify the imported asset and disclose the pending Neon mapping.")
		_assert(main_scene.save_project(), "The imported GLB UI state must save through the canonical BuildDocument path.")
		main_scene.queue_free()
		await process_frame

	var tampered_document: Dictionary = restored_document.duplicate(true)
	tampered_document["asset"]["sha256"] = "0000000000000000000000000000000000000000000000000000000000000000"
	var tampered_bike := BikeAssemblyScript.new()
	tampered_bike.configure_build_document(tampered_document)
	root.add_child(tampered_bike)
	await process_frame
	_assert(not tampered_bike.is_imported_model(), "A hash mismatch must refuse the imported asset and retain the safe placeholder.")
	_assert("fuel_tank" in tampered_bike.get_part_ids(), "Hash mismatch fallback must keep the garage usable.")

	_cleanup()
	if _failed:
		quit(1)
		return
	print("PASS: verified local GLB import, stable surface selection, isolated PBR edits and canonical save/reload.")

	quit(0)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		_failed = true
		push_error(message)

func _cleanup() -> void:
	_remove_if_exists(FIXTURE_PATH)
	_remove_if_exists(SAVE_PATH)
	_remove_if_exists(SAVE_PATH + ".tmp")
	_remove_if_exists(SAVE_PATH + ".bak")
	_remove_if_exists(MAIN_SAVE_PATH)
	_remove_if_exists(MAIN_SAVE_PATH + ".tmp")
	_remove_if_exists(MAIN_SAVE_PATH + ".bak")

func _remove_if_exists(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
