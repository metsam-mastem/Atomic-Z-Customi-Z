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
	for path in [BUILD_PATH, BUILD_PATH + ".tmp", BUILD_PATH + ".bak"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	quit(1 if _failed else 0)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		_failed = true
		push_error(message)
