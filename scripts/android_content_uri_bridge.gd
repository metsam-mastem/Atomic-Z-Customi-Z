extends Node

signal file_selected(content_uri: String, display_name: String)
signal file_picker_error(message: String)
signal file_picker_canceled
signal transfer_completed(local_path: String, success: bool, message: String)

const SINGLETON_NAME := "AndroidContentUri"

var _plugin: Object
var _transfer_results: Dictionary = {}


func _ready() -> void:
	if OS.get_name() != "Android":
		return
	if not Engine.has_singleton(SINGLETON_NAME):
		push_warning("Android ContentUri plugin is not present in this export.")
		return
	_plugin = Engine.get_singleton(SINGLETON_NAME)
	_connect_plugin_signal("file_selected", _on_file_selected)
	_connect_plugin_signal("file_picker_error", _on_picker_error)
	_connect_plugin_signal("file_picker_canceled", _on_picker_canceled)
	_connect_plugin_signal("file_imported", _on_file_imported)
	_connect_plugin_signal("file_transfer_error", _on_transfer_error)


func is_available() -> bool:
	return _plugin != null


func launch_file_picker_open_glb() -> bool:
	if not is_available():
		return false
	_plugin.call("launchFilePickerOpenFile", "*/*")
	return true


func import_file_and_wait(content_uri: String, local_path: String) -> Dictionary:
	if not is_available():
		return {"ok": false, "error": "Android ContentUri plugin is unavailable."}
	if not content_uri.begins_with("content://"):
		return {"ok": false, "error": "The selected Android document URI is not a content URI."}
	if not local_path.begins_with("user://") or not local_path.to_lower().ends_with(".glb"):
		return {"ok": false, "error": "Import destination must be a private user:// .glb path."}

	_transfer_results.erase(local_path)
	if not bool(_plugin.call("importFile", content_uri, local_path)):
		return {"ok": false, "error": "Android rejected the GLB copy request."}

	while not _transfer_results.has(local_path):
		await transfer_completed

	var result: Dictionary = _transfer_results[local_path]
	_transfer_results.erase(local_path)
	return result


func _connect_plugin_signal(signal_name: String, callback: Callable) -> void:
	if _plugin.has_signal(signal_name) and not _plugin.is_connected(signal_name, callback):
		_plugin.connect(signal_name, callback)


func _on_file_selected(content_uri: String, display_name: String) -> void:
	file_selected.emit(content_uri, display_name)


func _on_picker_error(message: String) -> void:
	file_picker_error.emit(message)


func _on_picker_canceled() -> void:
	file_picker_canceled.emit()


func _on_file_imported(local_path: String) -> void:
	_resolve_transfer(local_path, true, "")


func _on_transfer_error(local_path: String, message: String) -> void:
	_resolve_transfer(local_path, false, message)


func _resolve_transfer(local_path: String, succeeded: bool, message: String) -> void:
	_transfer_results[local_path] = {
		"ok": succeeded,
		"path": local_path,
		"error": message
	}
	transfer_completed.emit(local_path, succeeded, message)
