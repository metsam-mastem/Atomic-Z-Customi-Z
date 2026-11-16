extends Node

signal file_selected(content_uri: String, display_name: String)
signal file_picker_error(message: String)
signal file_picker_canceled
signal file_imported(local_path: String)
signal file_transfer_error(message: String)

const SINGLETON_NAME := "AndroidContentUri"

var _plugin: Object


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


func import_file(content_uri: String, local_path: String) -> bool:
	if not is_available() or not content_uri.begins_with("content://"):
		return false
	if not local_path.begins_with("user://") or not local_path.to_lower().ends_with(".glb"):
		return false
	return bool(_plugin.call("importFile", content_uri, local_path))


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
	file_imported.emit(local_path)


func _on_transfer_error(message: String) -> void:
	file_transfer_error.emit(message)
