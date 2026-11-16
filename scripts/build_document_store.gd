extends RefCounted
class_name BuildDocumentStore

const BuildDocumentScript = preload("res://scripts/build_document.gd")

static func save_document(document: Dictionary, path: String = "user://atomic_z_build.json") -> bool:
	if path.strip_edges().is_empty():
		return false
	if not BuildDocumentScript.validate(document).get("ok", false):
		return false

	var temporary_path := path + ".tmp"
	var backup_path := path + ".bak"
	_remove_if_exists(temporary_path)

	var file := FileAccess.open(temporary_path, FileAccess.WRITE)
	if file == null:
		push_error("BuildDocumentStore: cannot open temporary save file: " + path)
		return false
	file.store_string(BuildDocumentScript.to_json(document))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		push_error("BuildDocumentStore: temporary write failed: " + error_string(write_error))
		_remove_if_exists(temporary_path)
		return false

	var verified := _read_valid_document(temporary_path)
	if verified.is_empty():
		push_error("BuildDocumentStore: temporary document failed JSON/schema read-back validation.")
		_remove_if_exists(temporary_path)
		return false

	var destination_absolute := ProjectSettings.globalize_path(path)
	var backup_absolute := ProjectSettings.globalize_path(backup_path)

	# Recover an earlier valid backup before rotating the current primary.
	if FileAccess.file_exists(backup_path):
		var current_document := _read_valid_document(path)
		var backup_document := _read_valid_document(backup_path)
		if current_document.is_empty() and not backup_document.is_empty():
			_remove_if_exists(path)
			var recovery_error := DirAccess.rename_absolute(backup_absolute, destination_absolute)
			if recovery_error != OK:
				push_error("BuildDocumentStore: backup recovery failed: " + error_string(recovery_error))
				_remove_if_exists(temporary_path)
				return false
		else:
			_remove_if_exists(backup_path)

	var had_primary := FileAccess.file_exists(path)
	if had_primary:
		var backup_error := DirAccess.rename_absolute(destination_absolute, backup_absolute)
		if backup_error != OK:
			push_error("BuildDocumentStore: cannot rotate primary save to backup: " + error_string(backup_error))
			_remove_if_exists(temporary_path)
			return false

	var install_error := DirAccess.rename_absolute(
		ProjectSettings.globalize_path(temporary_path),
		destination_absolute
	)
	if install_error != OK:
		push_error("BuildDocumentStore: cannot install validated temporary save: " + error_string(install_error))
		if had_primary and FileAccess.file_exists(backup_path) and not FileAccess.file_exists(path):
			DirAccess.rename_absolute(backup_absolute, destination_absolute)
		_remove_if_exists(temporary_path)
		return false

	# Keep the previous valid revision as the recovery point until the next save.
	return true

static func load_document(path: String = "user://atomic_z_build.json") -> Dictionary:
	var primary := _read_valid_document(path)
	if not primary.is_empty():
		return primary

	var backup_path := path + ".bak"
	var backup := _read_valid_document(backup_path)
	if backup.is_empty():
		return {}

	# Restore the last known-good document when the primary is absent or corrupt.
	_remove_if_exists(path)
	var recovery_error := DirAccess.rename_absolute(
		ProjectSettings.globalize_path(backup_path),
		ProjectSettings.globalize_path(path)
	)
	if recovery_error == OK:
		return backup
	return backup

static func _read_valid_document(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed := BuildDocumentScript.from_json(file.get_as_text())
	file.close()
	return parsed

static func _remove_if_exists(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
