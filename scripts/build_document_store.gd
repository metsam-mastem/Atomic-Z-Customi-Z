extends RefCounted
class_name BuildDocumentStore

const BuildDocumentScript = preload("res://scripts/build_document.gd")

static func save_document(document: Dictionary, path: String = "user://atomic_z_build.json") -> bool:
	if path.strip_edges().is_empty() or not BuildDocumentScript.validate(document).get("ok", false):
		return false

	var temporary_path := path + ".tmp"
	var backup_path := path + ".bak"
	if not _remove_file_if_exists(temporary_path):
		return false

	if not _write_verified_document(document, temporary_path):
		_remove_file_if_exists(temporary_path)
		return false

	# If an earlier interrupted save left a backup, restore it first when the
	# primary is invalid. Never discard the only valid copy.
	if FileAccess.file_exists(backup_path):
		var primary_document := _read_valid_document(path)
		var backup_document := _read_valid_document(backup_path)
		if primary_document.is_empty() and not backup_document.is_empty():
			if not _restore_backup(path, backup_path):
				_remove_file_if_exists(temporary_path)
				return false
		elif primary_document.is_empty() and backup_document.is_empty():
			# Neither copy is valid. Keep the primary as a forensic artifact;
			# refuse to rotate it over the backup path.
			_remove_file_if_exists(temporary_path)
			return false
		else:
			if not _remove_file_if_exists(backup_path):
				_remove_file_if_exists(temporary_path)
				return false

	var had_primary := FileAccess.file_exists(path)
	if had_primary:
		var rotate_error := DirAccess.rename_absolute(
			ProjectSettings.globalize_path(path),
			ProjectSettings.globalize_path(backup_path)
		)
		if rotate_error != OK:
			push_error("BuildDocumentStore: cannot preserve current save: " + error_string(rotate_error))
			_remove_file_if_exists(temporary_path)
			return false

	var install_error := DirAccess.rename_absolute(
		ProjectSettings.globalize_path(temporary_path),
		ProjectSettings.globalize_path(path)
	)
	if install_error != OK:
		push_error("BuildDocumentStore: cannot install validated save: " + error_string(install_error))
		if had_primary:
			_restore_backup(path, backup_path)
		_remove_file_if_exists(temporary_path)
		return false

	var installed := _read_valid_document(path)
	if installed != document:
		push_error("BuildDocumentStore: installed document failed read-back verification.")
		_remove_file_if_exists(path)
		if had_primary:
			_restore_backup(path, backup_path)
		return false
	return true

static func load_document(path: String = "user://atomic_z_build.json") -> Dictionary:
	var primary := _read_valid_document(path)
	if not primary.is_empty():
		return primary

	var backup_path := path + ".bak"
	var backup := _read_valid_document(backup_path)
	if backup.is_empty():
		return {}

	# Restore through a verified temporary file and keep the backup intact.
	if _write_verified_document(backup, path + ".recovery.tmp"):
		var recovery_error := DirAccess.rename_absolute(
			ProjectSettings.globalize_path(path + ".recovery.tmp"),
			ProjectSettings.globalize_path(path)
		)
		if recovery_error != OK:
			_remove_file_if_exists(path + ".recovery.tmp")
	return backup

static func _write_verified_document(document: Dictionary, path: String) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("BuildDocumentStore: cannot open temporary file: " + path)
		return false
	file.store_string(BuildDocumentScript.to_json(document))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		push_error("BuildDocumentStore: write failed: " + error_string(write_error))
		return false
	return _read_valid_document(path) == document

static func _read_valid_document(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var result := BuildDocumentScript.from_json(file.get_as_text())
	file.close()
	return result

static func _restore_backup(path: String, backup_path: String) -> bool:
	if not FileAccess.file_exists(backup_path) or not _read_valid_document(backup_path).is_empty() == false:
		return false
	_remove_file_if_exists(path)
	var recovery_error := DirAccess.rename_absolute(
		ProjectSettings.globalize_path(backup_path),
		ProjectSettings.globalize_path(path)
	)
	if recovery_error == OK:
		return true
	push_error("BuildDocumentStore: backup restore failed: " + error_string(recovery_error))
	return false

static func _remove_file_if_exists(path: String) -> bool:
	if not FileAccess.file_exists(path):
		return true
	var remove_error := DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	if remove_error != OK:
		push_error("BuildDocumentStore: cannot remove temporary/obsolete file: " + error_string(remove_error))
		return false
	return true
