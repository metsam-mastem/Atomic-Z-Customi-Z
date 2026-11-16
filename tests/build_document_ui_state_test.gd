extends SceneTree

const BuildDocumentScript = preload("res://scripts/build_document.gd")
const BuildDocumentStoreScript = preload("res://scripts/build_document_store.gd")

const BUILD_PATH := "user://atomic_z_build.json"
const PROFILE_PATH := "user://skin_profile.json"

var _failed := false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _test_legacy_profile_migration_contract()
	await _test_legacy_profile_startup_migration()
	await _test_canonical_document_precedence_and_hud_hydration()
	_cleanup_user_files()
	quit(1 if _failed else 0)

func _test_legacy_profile_migration_contract() -> void:
	var source := BuildDocumentScript.create_default("migration-test-bike", "Migration Test Bike")
	source["render"]["glow_intensity"] = 0.35
	var source_before := source.duplicate(true)
	var legacy_profile := {
		"schema_version": 1.0,
		"color": "#224466FF",
		"glow_intensity": 3.5,
		"pulse_speed": 2.25
	}

	var migrated: Dictionary = BuildDocumentScript.from_legacy_skin_profile(legacy_profile, source)
	_assert(not migrated.is_empty(), "A valid legacy shader profile must migrate.")
	_assert(BuildDocumentScript.validate(migrated).get("ok", false), "Migrated profile must remain a valid BuildDocument.")
	_assert(migrated.get("customization", {}).get("palette", {}).get("primary") == "#224466FF", "Legacy profile color must migrate into the canonical primary palette.")
	_assert(is_equal_approx(float(migrated.get("render", {}).get("glow_intensity", -1.0)), 0.35), "Legacy 0..10 intensity must not be reinterpreted as canonical 0..1 glow.")
	_assert(_documents_equivalent(source, source_before), "Profile migration must not mutate the source BuildDocument.")

	var extensions: Array = migrated.get("extensions", [])
	_assert(extensions.size() == 1, "Legacy shader values must be preserved in one versioned extension.")
	if extensions.size() == 1:
		var extension: Dictionary = extensions[0]
		var payload: Dictionary = extension.get("payload", {})
		_assert(extension.get("extension_id") == "legacy_neon_shader_profile", "Legacy profile extension must use a stable extension ID.")
		_assert(extension.get("status") == "preserved_unmapped", "Unmapped legacy values must be explicitly marked.")
		_assert(is_equal_approx(float(payload.get("glow_intensity_legacy_0_10", -1.0)), 3.5), "Legacy glow intensity must be preserved without unit conversion.")
		_assert(is_equal_approx(float(payload.get("pulse_speed_legacy_0_10", -1.0)), 2.25), "Legacy pulse speed must be preserved without unit conversion.")

	_assert(BuildDocumentScript.from_legacy_skin_profile(legacy_profile, migrated).is_empty(), "The same legacy profile must not be imported twice.")
	var invalid_range := legacy_profile.duplicate(true)
	invalid_range["pulse_speed"] = 11.0
	_assert(BuildDocumentScript.from_legacy_skin_profile(invalid_range, source).is_empty(), "Out-of-range legacy values must be rejected.")
	var invalid_color := legacy_profile.duplicate(true)
	invalid_color["color"] = "not-a-color"
	_assert(BuildDocumentScript.from_legacy_skin_profile(invalid_color, source).is_empty(), "Invalid legacy colors must be rejected.")
	var invalid_schema := legacy_profile.duplicate(true)
	invalid_schema["schema_version"] = 2
	_assert(BuildDocumentScript.from_legacy_skin_profile(invalid_schema, source).is_empty(), "Unsupported legacy profile schema versions must be rejected.")

func _test_legacy_profile_startup_migration() -> void:
	_cleanup_user_files()
	var legacy_profile := {
		"schema_version": 1.0,
		"color": "#224466FF",
		"glow_intensity": 3.5,
		"pulse_speed": 2.25
	}
	_write_json(PROFILE_PATH, legacy_profile)

	var packed_scene := load("res://scenes/main.tscn") as PackedScene
	_assert(packed_scene != null, "Main garage scene must load for legacy profile migration.")
	if packed_scene == null:
		return

	var scene := packed_scene.instantiate()
	root.add_child(scene)
	await process_frame

	var snapshot: Dictionary = scene.call("get_build_document_snapshot")
	_assert(snapshot.get("customization", {}).get("palette", {}).get("primary") == "#224466FF", "First launch must migrate the legacy profile color into BuildDocument.")
	var vehicle: Dictionary = snapshot.get("vehicle", {})
	_assert(vehicle.get("model_year") == 2026, "First launch must hydrate the selected 2026 model-year reference.")
	_assert(vehicle.get("variant") == "ZX-25RR", "First launch must hydrate the selected ZX-25RR variant.")
	_assert(vehicle.get("market") == null, "First launch must not infer a regional market.")
	_assert(snapshot.get("asset", {}).get("validation_status") == "not_run", "Vehicle identity metadata must not imply validated production geometry.")
	_assert(is_equal_approx(float(snapshot.get("render", {}).get("glow_intensity", -1.0)), 0.8), "First launch must preserve the existing canonical glow value instead of converting legacy 0..10 intensity.")
	var extensions: Array = snapshot.get("extensions", [])
	_assert(extensions.size() == 1, "First launch must preserve legacy shader parameters in a BuildDocument extension.")

	var persisted := BuildDocumentStoreScript.load_document(BUILD_PATH)
	_assert(not persisted.is_empty(), "Successful migration must persist a readable canonical BuildDocument.")
	_assert(persisted.get("customization", {}).get("palette", {}).get("primary") == "#224466FF", "Persisted BuildDocument must retain the migrated legacy color.")
	var persisted_extensions: Array = persisted.get("extensions", [])
	_assert(persisted_extensions.size() == 1, "Persisted BuildDocument must retain the legacy profile extension.")
	if persisted_extensions.size() == 1:
		var persisted_payload: Dictionary = persisted_extensions[0].get("payload", {})
		_assert(is_equal_approx(float(persisted_payload.get("glow_intensity_legacy_0_10", -1.0)), 3.5), "Persisted BuildDocument must retain legacy glow intensity.")
		_assert(is_equal_approx(float(persisted_payload.get("pulse_speed_legacy_0_10", -1.0)), 2.25), "Persisted BuildDocument must retain legacy pulse speed.")
	_assert(FileAccess.file_exists(PROFILE_PATH), "Migration must retain the original legacy profile file.")
	var profile_file := FileAccess.open(PROFILE_PATH, FileAccess.READ)
	if profile_file != null:
		var retained_profile: Variant = JSON.parse_string(profile_file.get_as_text())
		profile_file.close()
		_assert(retained_profile == legacy_profile, "Migration must not rewrite or delete the original legacy profile.")
	else:
		_assert(false, "Original legacy profile must remain readable after migration.")

	scene.queue_free()
	await process_frame
	_cleanup_user_files()

func _test_canonical_document_precedence_and_hud_hydration() -> void:
	var document := BuildDocumentScript.create_default("ui-state-test-bike", "UI State Test Bike")
	document["customization"]["palette"]["primary"] = "#123456"
	document["customization"]["palette"]["secondary"] = "#ABCDEF"
	document["render"]["glow_intensity"] = 0.35
	_assert(BuildDocumentStoreScript.save_document(document, BUILD_PATH), "Test BuildDocument must be saved before opening the garage.")

	var conflicting_profile := {
		"schema_version": 1.0,
		"color": "#ABCDEF",
		"glow_intensity": 7.0,
		"pulse_speed": 4.0
	}
	_write_json(PROFILE_PATH, conflicting_profile)

	var packed_scene := load("res://scenes/main.tscn") as PackedScene
	_assert(packed_scene != null, "Main garage scene must load.")
	if packed_scene == null:
		return

	var scene := packed_scene.instantiate()
	root.add_child(scene)
	await process_frame

	var snapshot: Dictionary = scene.call("get_build_document_snapshot")
	_assert(snapshot.get("customization", {}).get("palette", {}).get("primary") == "#123456", "An existing canonical BuildDocument must take precedence over a legacy profile.")
	_assert(snapshot.get("extensions", []).is_empty(), "A legacy profile must not be imported when a valid canonical BuildDocument exists.")

	var primary_picker := scene.find_child("NeonPrimaryPicker", true, false) as ColorPickerButton
	var secondary_picker := scene.find_child("NeonSecondaryPicker", true, false) as ColorPickerButton
	var glow_slider := scene.find_child("NeonGlowSlider", true, false) as HSlider
	_assert(primary_picker != null, "Garage HUD must expose its primary neon picker.")
	_assert(secondary_picker != null, "Garage HUD must expose its secondary neon picker.")
	_assert(glow_slider != null, "Garage HUD must expose its glow slider.")

	if primary_picker != null:
		_assert(primary_picker.color.is_equal_approx(Color("#123456")), "Primary neon picker must hydrate from the canonical BuildDocument.")
	if secondary_picker != null:
		_assert(secondary_picker.color.is_equal_approx(Color("#ABCDEF")), "Secondary neon picker must hydrate from the canonical BuildDocument.")
	if glow_slider != null:
		_assert(is_equal_approx(glow_slider.value, 0.35), "Glow slider must hydrate from the canonical BuildDocument.")

	_assert(FileAccess.file_exists(PROFILE_PATH), "A skipped legacy migration must leave the original profile untouched.")
	scene.queue_free()
	await process_frame

func _documents_equivalent(left: Dictionary, right: Dictionary) -> bool:
	var normalized_left: Variant = JSON.parse_string(BuildDocumentScript.to_json(left))
	var normalized_right: Variant = JSON.parse_string(BuildDocumentScript.to_json(right))
	return normalized_left == normalized_right

func _write_json(path: String, value: Dictionary) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	_assert(file != null, "Test fixture must open for writing: " + path)
	if file != null:
		file.store_string(JSON.stringify(value, "\t"))
		file.close()

func _cleanup_user_files() -> void:
	for path in [BUILD_PATH, BUILD_PATH + ".tmp", BUILD_PATH + ".bak", PROFILE_PATH]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _assert(condition: bool, message: String) -> void:
	if not condition:
		_failed = true
		push_error(message)
