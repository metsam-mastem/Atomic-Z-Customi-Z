extends SceneTree

const BuildDocumentScript = preload("res://scripts/build_document.gd")
const StoreScript = preload("res://scripts/build_document_store.gd")

var _failed := false

func _initialize() -> void:
	var legacy := {
		"bike_model": "Kawasaki Ninja ZX-25R",
		"skin_name": "Neon Cyberpunk",
		"colors": {
			"primary": "#00FFCC",
			"secondary": "#FF00FF",
			"glow_intensity": 0.8
		},
		"line_segments": [
			{"id": "tail_underglow", "color": "primary", "width": 2.0, "visible": true, "points": [[100, 300], [200, 320]]}
		]
	}
	var document: Dictionary = BuildDocumentScript.from_legacy_neon(legacy)
	_assert(document.get("schema_version") == 1, "Migration must stamp schema version 1.")
	_assert(document.get("vehicle", {}).get("vehicle_id") == "kawasaki-ninja-zx-25r", "Migration must create a stable vehicle ID.")
	_assert(document.get("customization", {}).get("neon_layers", []).size() == 1, "Migration must preserve neon segments.")
	_assert(BuildDocumentScript.validate(document).get("ok", false), "Migrated document must validate.")

	var encoded: String = BuildDocumentScript.to_json(document)
	var decoded: Dictionary = BuildDocumentScript.from_json(encoded)
	_assert(decoded == document, "BuildDocument JSON round-trip must preserve all data.")

	var save_path := "user://atomic_z_store_contract_test.json"
	_remove_if_exists(save_path)
	_remove_if_exists(save_path + ".tmp")
	_remove_if_exists(save_path + ".bak")
	var initial := BuildDocumentScript.create_default("test-bike", "Test Bike")
	initial["revision"] = 1
	_assert(StoreScript.save_document(initial, save_path), "A valid document must save.")
	var invalid_for_save := initial.duplicate(true)
	invalid_for_save["schema_version"] = 999
	_assert(not StoreScript.save_document(invalid_for_save, save_path), "An invalid document must not overwrite a valid save.")
	_assert(StoreScript.load_document(save_path) == initial, "A rejected save must preserve the previous valid document.")

	var backup_directory := ProjectSettings.globalize_path(save_path + ".bak")
	_assert(DirAccess.make_dir_absolute(backup_directory) == OK, "A conflicting backup directory fixture must be created.")
	_assert(not StoreScript.save_document(initial, save_path), "A failed backup rotation must reject the new save.")
	_assert(StoreScript.load_document(save_path) == initial, "A failed backup rotation must preserve the last valid primary save.")
	DirAccess.remove_absolute(backup_directory)

	var newer := initial.duplicate(true)
	newer["revision"] = 2
	_assert(StoreScript.save_document(newer, save_path), "A second valid document must replace the previous save.")
	_assert(StoreScript.load_document(save_path) == newer, "The latest valid document must round-trip.")
	_assert(FileAccess.file_exists(save_path + ".bak"), "The previous valid revision must remain available as a backup.")
	var backup_file := FileAccess.open(save_path + ".bak", FileAccess.READ)
	var backup_document: Dictionary = BuildDocumentScript.from_json(backup_file.get_as_text()) if backup_file != null else {}
	if backup_file != null:
		backup_file.close()
	_assert(backup_document == initial, "The retained backup must contain the previous valid revision.")

	_write_text(save_path, "{broken-json")
	_write_text(save_path + ".bak", BuildDocumentScript.to_json(newer))
	_assert(StoreScript.load_document(save_path) == newer, "A valid backup must recover a corrupt primary save.")

	_remove_if_exists(save_path)
	_write_text(save_path + ".bak", BuildDocumentScript.to_json(initial))
	_assert(StoreScript.load_document(save_path) == initial, "A valid backup must recover a missing primary save.")

	_remove_if_exists(save_path)
	_remove_if_exists(save_path + ".tmp")
	_remove_if_exists(save_path + ".bak")

	var invalid := document.duplicate(true)
	invalid["schema_version"] = 999
	_assert(not BuildDocumentScript.validate(invalid).get("ok", true), "Unknown schema versions must be rejected.")

	quit(1 if _failed else 0)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		_failed = true
		push_error(message)

func _write_text(path: String, value: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	_assert(file != null, "Test fixture file must open for writing.")
	if file != null:
		file.store_string(value)
		file.close()

func _remove_if_exists(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
