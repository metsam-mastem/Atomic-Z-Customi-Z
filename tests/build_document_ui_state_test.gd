extends SceneTree

const BuildDocumentScript = preload("res://scripts/build_document.gd")
const BuildDocumentStoreScript = preload("res://scripts/build_document_store.gd")

const BUILD_PATH := "user://atomic_z_build.json"

var _failed := false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var document := BuildDocumentScript.create_default("ui-state-test-bike", "UI State Test Bike")
	document["customization"]["palette"]["primary"] = "#123456"
	document["customization"]["palette"]["secondary"] = "#ABCDEF"
	document["render"]["glow_intensity"] = 0.35
	_assert(BuildDocumentStoreScript.save_document(document, BUILD_PATH), "Test BuildDocument must be saved before opening the garage.")

	var packed_scene := load("res://scenes/main.tscn") as PackedScene
	_assert(packed_scene != null, "Main garage scene must load.")
	if packed_scene == null:
		quit(1)
		return

	var scene := packed_scene.instantiate()
	root.add_child(scene)
	await process_frame

	var primary_picker := scene.find_child("NeonPrimaryPicker", true, false) as ColorPickerButton
	var secondary_picker := scene.find_child("NeonSecondaryPicker", true, false) as ColorPickerButton
	var glow_slider := scene.find_child("NeonGlowSlider", true, false) as HSlider

	_assert(primary_picker != null, "Garage HUD must expose its primary neon picker.")
	_assert(secondary_picker != null, "Garage HUD must expose its secondary neon picker.")
	_assert(glow_slider != null, "Garage HUD must expose its glow slider.")

	if primary_picker != null:
		_assert(primary_picker.color.is_equal_approx(Color("#123456")), "Primary neon picker must hydrate from the loaded BuildDocument.")
	if secondary_picker != null:
		_assert(secondary_picker.color.is_equal_approx(Color("#ABCDEF")), "Secondary neon picker must hydrate from the loaded BuildDocument.")
	if glow_slider != null:
		_assert(is_equal_approx(glow_slider.value, 0.35), "Glow slider must hydrate from the loaded BuildDocument.")

	scene.queue_free()
	await process_frame
	for path in [BUILD_PATH, BUILD_PATH + ".tmp", BUILD_PATH + ".bak"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

	# First-launch migration must preserve legacy user data in the one canonical document.
	const legacy_profile_path := "user://skin_profile.json"
	var legacy_profile := {
		"schema_version": 1,
		"color": "#224466FF",
		"glow_intensity": 3.5,
		"pulse_speed": 2.25
	}
	_write_text(legacy_profile_path, JSON.stringify(legacy_profile))
	var migration_scene := packed_scene.instantiate()
	root.add_child(migration_scene)
	await process_frame

	var migrated_document: Dictionary = migration_scene.call("get_build_document_snapshot")
	_assert(migrated_document.get("customization", {}).get("palette", {}).get("primary") == "#224466FF", "First launch must import the legacy profile color into BuildDocument.")
	var migrated_extensions: Array = migrated_document.get("extensions", [])
	_assert(migrated_extensions.size() == 1, "First launch must preserve the legacy shader profile as one extension.")
	if migrated_extensions.size() == 1:
		var payload: Dictionary = migrated_extensions[0].get("payload", {})
		_assert(is_equal_approx(float(payload.get("glow_intensity_legacy_0_10", -1.0)), 3.5), "First launch must preserve the legacy 0..10 glow value.")
		_assert(is_equal_approx(float(payload.get("pulse_speed_legacy_0_10", -1.0)), 2.25), "First launch must preserve the legacy 0..10 pulse value.")
	var persisted_migration := BuildDocumentStoreScript.load_document(BUILD_PATH)
	_assert(not persisted_migration.is_empty(), "First-launch profile migration must persist a canonical BuildDocument.")
	_assert(persisted_migration.get("extensions", []).size() == 1, "Persisted BuildDocument must contain the migrated legacy profile.")
	_assert(FileAccess.file_exists(legacy_profile_path), "Migration must retain the original legacy profile file.")

	migration_scene.queue_free()
	await process_frame
	for path in [BUILD_PATH, BUILD_PATH + ".tmp", BUILD_PATH + ".bak", legacy_profile_path]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	quit(1 if _failed else 0)

func _write_text(path: String, value: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	_assert(file != null, "Legacy profile test fixture must be writable.")
	if file != null:
		file.store_string(value)
		file.close()

func _assert(condition: bool, message: String) -> void:
	if not condition:
		_failed = true
		push_error(message)
