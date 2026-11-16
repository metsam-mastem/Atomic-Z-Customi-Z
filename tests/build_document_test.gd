extends SceneTree

const BuildDocumentScript = preload("res://scripts/build_document.gd")
const StoreScript = preload("res://scripts/build_document_store.gd")

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
	_remove_file_if_exists(save_path)
	_remove_file_if_exists(save_path + ".tmp")
	_remove_file_if_exists(save_path + ".bak")
	var initial := BuildDocumentScript.create_default("test-bike", "Test Bike")
	initial["revision"] = 1
	_assert(StoreScript.save_document(initial, save_path), "A valid document must save.")
	_assert(StoreScript.load_document(save_path) == initial, "A valid save must round-trip.")

	var invalid_for_save := initial.duplicate(true)
	invalid_for_save["schema_version"] = 999
	_assert(not StoreScript.save_document(invalid_for_save, save_path), "An invalid document must be rejected.")
	_assert(StoreScript.load_document(save_path) == initial, "An invalid save must preserve the last valid primary.")

	var backup_directory := ProjectSettings.globalize_path(save_path + ".bak")
	_assert(DirAccess.make_dir_absolute(backup_directory) == OK, "A conflicting backup directory fixture must be created.")
	_assert(not StoreScript.save_document(initial, save_path), "A failed backup rotation must reject the new save.")
	_assert(StoreScript.load_document(save_path) == initial, "A failed backup rotation must preserve the last valid primary.")
	_assert(DirAccess.remove_absolute(backup_directory) == OK, "The backup directory fixture must be removed.")

	var newer := initial.duplicate(true)
	newer["revision"] = 2
	_assert(StoreScript.save_document(newer, save_path), "A subsequent valid save must succeed.")
	_assert(StoreScript.load_document(save_path) == newer, "The newest valid document must round-trip.")
	_assert(_read_document(save_path + ".bak") == initial, "The previous valid revision must remain as backup.")

	_write_text(save_path, "{broken-json")
	_assert(StoreScript.load_document(save_path) == initial, "A corrupt primary must recover from the previous valid backup.")
	_assert(_read_document(save_path) == initial, "Backup recovery must restore the primary file.")

	_remove_file_if_exists(save_path)
	_remove_file_if_exists(save_path + ".tmp")
	_remove_file_if_exists(save_path + ".bak")

	var invalid := document.duplicate(true)
	invalid["schema_version"] = 999
	_assert(not BuildDocumentScript.validate(invalid).get("ok", true), "Unknown schema versions must be rejected.")
	quit(0)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		quit(1)

func _read_document(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var result := BuildDocumentScript.from_json(file.get_as_text())
	file.close()
	return result

func _write_text(path: String, value: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	_assert(file != null, "Test fixture file must open for writing.")
	if file != null:
		file.store_string(value)
		file.flush()
		file.close()

func _remove_file_if_exists(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
