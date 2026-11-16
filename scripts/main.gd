extends Node3D

const BikeAssemblyScript = preload("res://scripts/bike_assembly.gd")
const QualityControllerScript = preload("res://scripts/quality_controller.gd")
const NeonSkinScript = preload("res://scripts/neon_skin.gd")
const BuildDocumentScript = preload("res://scripts/build_document.gd")
const BuildDocumentStoreScript = preload("res://scripts/build_document_store.gd")
const GarageTouchGesturesScript = preload("res://scripts/garage_touch_gestures.gd")

var _bike
var _camera: Camera3D
var _key_light: DirectionalLight3D
var _quality
var _neon_skin
var _build_document: Dictionary = {}
var _part_selector: OptionButton
var _paint_picker: ColorPickerButton
var _build_summary_label: Label
var _selected_part_id := "fuel_tank"
const BUILD_DOCUMENT_PATH := "user://atomic_z_build.json"
var _orbit_angle := 0.0
var _orbit_pitch := 0.16
var _orbit_distance := 5.3
var _camera_target_offset := Vector3.ZERO
var _touch_gestures
var _dragging := false
var _last_pointer := Vector2.ZERO

func _ready() -> void:
	_touch_gestures = GarageTouchGesturesScript.new()
	_build_document = _load_initial_build_document()
	_build_world()
	_bike = BikeAssemblyScript.new()
	_bike.name = "MotorcyclePlaceholder"
	_bike.configure_build_document(_build_document)
	add_child(_bike)
	_quality = QualityControllerScript.new()
	add_child(_quality)
	_quality.configure(_key_light)
	_neon_skin = NeonSkinScript.new()
	_neon_skin.name = "NeonSkinOverlay"
	_neon_skin.configure_build_document(_build_document)
	_neon_skin.position.z = 0.29
	add_child(_neon_skin)
	_update_camera()
	_build_hud()

func _build_world() -> void:
	var world := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#111923")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#8796a8")
	environment.ambient_light_energy = 0.65
	world.environment = environment
	add_child(world)

	_key_light = DirectionalLight3D.new()
	_key_light.rotation_degrees = Vector3(-42.0, -28.0, 0.0)
	_key_light.light_energy = 1.35
	_key_light.shadow_enabled = true
	add_child(_key_light)

	var fill := OmniLight3D.new()
	fill.position = Vector3(-2.0, 3.0, 2.0)
	fill.light_color = Color("#5c9acb")
	fill.light_energy = 0.65
	fill.omni_range = 8.0
	add_child(fill)

	var floor_mesh := MeshInstance3D.new()
	var floor := PlaneMesh.new()
	floor.size = Vector2(18.0, 18.0)
	floor_mesh.mesh = floor
	var floor_material := StandardMaterial3D.new()
	floor_material.albedo_color = Color("#202a34")
	floor_material.roughness = 0.82
	floor_mesh.material_override = floor_material
	floor_mesh.position.y = -0.02
	add_child(floor_mesh)

	_camera = Camera3D.new()
	_camera.current = true
	_camera.fov = 42.0
	add_child(_camera)

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.name = "HUDRoot"
	layer.name = "GarageHUD"
	layer.add_child(root)

	var title := Label.new()
	title.text = "ATOMIC Z  /  CUSTOMIZATION LAB"
	title.position = Vector2(24.0, 20.0)
	title.add_theme_font_size_override("font_size", 20)
	root.add_child(title)

	var hint := Label.new()
	hint.text = "1 FINGER ORBIT  •  2 FINGER PAN / PINCH ZOOM  •  WHEEL ZOOM"
	hint.position = Vector2(24.0, 52.0)
	hint.add_theme_font_size_override("font_size", 12)
	hint.modulate = Color("#aab8c8")
	root.add_child(hint)

	var controls := HBoxContainer.new()
	controls.position = Vector2(24.0, 94.0)
	controls.add_theme_constant_override("separation", 10)
	root.add_child(controls)

	_part_selector = OptionButton.new()
	_part_selector.custom_minimum_size = Vector2(180.0, 42.0)
	_populate_part_selector()
	_part_selector.item_selected.connect(_on_part_selected)
	controls.add_child(_part_selector)

	var assembly_button := Button.new()
	assembly_button.text = "EXPLODED / STOCK"
	assembly_button.pressed.connect(_on_toggle_assembly)
	controls.add_child(assembly_button)

	_paint_picker = ColorPickerButton.new()
	_paint_picker.color = _bike.get_part_color(_selected_part_id)
	_paint_picker.custom_minimum_size = Vector2(54.0, 42.0)
	_paint_picker.tooltip_text = "Paint selected part"
	_paint_picker.color_changed.connect(_on_body_color_changed)
	controls.add_child(_paint_picker)

	var reset_button := Button.new()
	reset_button.text = "RESET CAMERA"
	reset_button.pressed.connect(_on_reset_camera)
	controls.add_child(reset_button)

	var neon_button := Button.new()
	neon_button.text = "NEON ON / OFF"
	neon_button.toggle_mode = true
	neon_button.button_pressed = bool(_build_document.get("render", {}).get("neon_enabled", true))
	neon_button.toggled.connect(_on_neon_toggled)
	controls.add_child(neon_button)

	var skin_controls := HBoxContainer.new()
	skin_controls.position = Vector2(24.0, 146.0)
	skin_controls.add_theme_constant_override("separation", 10)
	root.add_child(skin_controls)

	_add_neon_segment_toggle(skin_controls, "TAIL", "tail_underglow")
	_add_neon_segment_toggle(skin_controls, "TANK", "tank_accent")
	_add_neon_segment_toggle(skin_controls, "LOWER", "lower_fairing")

	var palette: Dictionary = _build_document.get("customization", {}).get("palette", {})
	var primary_picker := ColorPickerButton.new()
	primary_picker.name = "NeonPrimaryPicker"
	primary_picker.color = Color.from_string(str(palette.get("primary", "#00FFCC")), Color("#00FFCC"))
	primary_picker.custom_minimum_size = Vector2(42.0, 42.0)
	primary_picker.tooltip_text = "Neon primary color"
	primary_picker.color_changed.connect(_on_neon_primary_changed)
	skin_controls.add_child(primary_picker)

	var secondary_picker := ColorPickerButton.new()
	secondary_picker.name = "NeonSecondaryPicker"
	secondary_picker.color = Color.from_string(str(palette.get("secondary", "#FF00FF")), Color("#FF00FF"))
	secondary_picker.custom_minimum_size = Vector2(42.0, 42.0)
	secondary_picker.tooltip_text = "Neon secondary color"
	secondary_picker.color_changed.connect(_on_neon_secondary_changed)
	skin_controls.add_child(secondary_picker)

	var glow_slider := HSlider.new()
	glow_slider.name = "NeonGlowSlider"
	glow_slider.custom_minimum_size = Vector2(120.0, 32.0)
	glow_slider.min_value = 0.0
	glow_slider.max_value = 1.0
	glow_slider.step = 0.05
	glow_slider.value = float(_build_document.get("render", {}).get("glow_intensity", 0.8))
	glow_slider.tooltip_text = "Neon glow intensity"
	glow_slider.value_changed.connect(_on_glow_changed)
	skin_controls.add_child(glow_slider)

	var save_skin_button := Button.new()
	save_skin_button.text = "SAVE PROJECT"
	save_skin_button.pressed.connect(_on_save_neon_skin)
	skin_controls.add_child(save_skin_button)

	var disclaimer := Label.new()
	disclaimer.text = "CONCEPT PLACEHOLDER — NOT FACTORY CAD / NOT ENGINEERING-VALIDATED"
	disclaimer.anchor_left = 0.0
	disclaimer.anchor_top = 1.0
	disclaimer.anchor_right = 1.0
	disclaimer.anchor_bottom = 1.0
	disclaimer.offset_left = 24.0
	disclaimer.offset_top = -34.0
	disclaimer.offset_right = -24.0
	disclaimer.offset_bottom = -10.0
	disclaimer.add_theme_font_size_override("font_size", 11)
	disclaimer.modulate = Color("#aab8c8")
	root.add_child(disclaimer)

	_build_summary_label = Label.new()
	_build_summary_label.name = "BuildSummaryLabel"
	_build_summary_label.anchor_left = 1.0
	_build_summary_label.anchor_right = 1.0
	_build_summary_label.offset_left = -390.0
	_build_summary_label.offset_right = -24.0
	_build_summary_label.offset_top = 20.0
	_build_summary_label.offset_bottom = 130.0
	_build_summary_label.add_theme_font_size_override("font_size", 14)
	_build_summary_label.modulate = Color("#e6edf5")
	_build_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_build_summary_label)
	_refresh_build_summary()

func _on_toggle_assembly() -> void:
	_bike.toggle_exploded()
	_refresh_build_summary()

func _on_body_color_changed(color: Color) -> void:
	if not _bike.set_part_color(_selected_part_id, color):
		push_warning("Selected part does not support paint editing: " + _selected_part_id)
	_refresh_build_summary()

func _populate_part_selector() -> void:
	_part_selector.clear()
	var selected_index := -1
	for part_id in _bike.get_part_ids():
		var index := _part_selector.item_count
		_part_selector.add_item(_bike.get_part_display_name(part_id))
		_part_selector.set_item_metadata(index, part_id)
		if part_id == _selected_part_id:
			selected_index = index
	if selected_index < 0 and _part_selector.item_count > 0:
		selected_index = 0
	if selected_index >= 0:
		_part_selector.select(selected_index)
		_selected_part_id = str(_part_selector.get_item_metadata(selected_index))

func _on_part_selected(index: int) -> void:
	if index < 0 or index >= _part_selector.item_count:
		return
	_selected_part_id = str(_part_selector.get_item_metadata(index))
	if is_instance_valid(_paint_picker):
		_paint_picker.color = _bike.get_part_color(_selected_part_id)
	_refresh_build_summary()

func _add_neon_segment_toggle(parent: Control, label_text: String, segment_id: String) -> void:
	var segment_button := Button.new()
	segment_button.text = label_text
	segment_button.toggle_mode = true
	segment_button.button_pressed = _neon_skin.is_segment_visible(segment_id)
	segment_button.toggled.connect(_on_neon_segment_toggled.bind(segment_id))
	parent.add_child(segment_button)

func _on_neon_segment_toggled(enabled: bool, segment_id: String) -> void:
	if is_instance_valid(_neon_skin):
		_neon_skin.set_segment_visible(segment_id, enabled)

func _on_neon_primary_changed(color: Color) -> void:
	if is_instance_valid(_neon_skin):
		_neon_skin.set_palette_color("primary", color)

func _on_neon_secondary_changed(color: Color) -> void:
	if is_instance_valid(_neon_skin):
		_neon_skin.set_palette_color("secondary", color)

func _on_neon_toggled(enabled: bool) -> void:
	if is_instance_valid(_neon_skin):
		_neon_skin.set_skin_visible(enabled)

func _on_glow_changed(value: float) -> void:
	if is_instance_valid(_neon_skin):
		_neon_skin.set_glow_intensity(value)

func _on_save_neon_skin() -> void:
	if not _save_build_document():
		push_warning("Could not save the unified build document.")
	else:
		_refresh_build_summary()

func _on_reset_camera() -> void:
	if is_instance_valid(_touch_gestures):
		_touch_gestures.reset()
	_camera_target_offset = Vector3.ZERO
	_orbit_angle = 0.0
	_orbit_pitch = 0.16
	_orbit_distance = 5.3
	_update_camera()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		_touch_gestures.sync_camera_state(_orbit_angle, _orbit_pitch, _orbit_distance, _camera_target_offset)
		_touch_gestures.handle_event(event)
		_apply_touch_camera_state()
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_dragging = event.pressed
			_last_pointer = event.position
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_orbit_distance = maxf(3.0, _orbit_distance - 0.35)
			_update_camera()
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_orbit_distance = minf(8.0, _orbit_distance + 0.35)
			_update_camera()
	elif event is InputEventMouseMotion and _dragging:
		_apply_orbit_drag(event.position)

func _apply_touch_camera_state() -> void:
	var state: Dictionary = _touch_gestures.get_camera_state()
	_orbit_angle = float(state.get("orbit_angle", _orbit_angle))
	_orbit_pitch = float(state.get("orbit_pitch", _orbit_pitch))
	_orbit_distance = float(state.get("orbit_distance", _orbit_distance))
	_camera_target_offset = Vector3(state.get("target_offset", _camera_target_offset))
	_update_camera()

func _apply_orbit_drag(pointer: Vector2) -> void:
	var delta := pointer - _last_pointer
	_last_pointer = pointer
	_orbit_angle -= delta.x * 0.008
	_orbit_pitch = clampf(_orbit_pitch + delta.y * 0.004, -0.12, 0.62)
	_update_camera()

func _update_camera() -> void:
	if not is_instance_valid(_camera):
		return
	var target := Vector3(0.0, 0.92, 0.0) + _camera_target_offset
	var horizontal := cos(_orbit_pitch) * _orbit_distance
	_camera.position = target + Vector3(
		sin(_orbit_angle) * horizontal,
		sin(_orbit_pitch) * _orbit_distance,
		cos(_orbit_angle) * horizontal
	)
	_camera.look_at(target, Vector3.UP)

func _load_initial_build_document() -> Dictionary:
	var restored := BuildDocumentStoreScript.load_document(BUILD_DOCUMENT_PATH)
	if not restored.is_empty():
		return restored

	var document := BuildDocumentScript.create_target_default()
	var legacy_neon_file := FileAccess.open("res://neon_skin_config.json", FileAccess.READ)
	if legacy_neon_file != null:
		var legacy_neon: Variant = JSON.parse_string(legacy_neon_file.get_as_text())
		legacy_neon_file.close()
		if legacy_neon is Dictionary:
			var migrated_neon: Dictionary = BuildDocumentScript.from_legacy_neon(legacy_neon)
			if BuildDocumentScript.validate(migrated_neon).get("ok", false):
				document = migrated_neon

	# Import the retired profile only when no valid canonical BuildDocument exists.
	# The source file is retained; all future writes use BuildDocumentStore.
	var legacy_profile_file := FileAccess.open("user://skin_profile.json", FileAccess.READ)
	if legacy_profile_file != null:
		var legacy_profile: Variant = JSON.parse_string(legacy_profile_file.get_as_text())
		legacy_profile_file.close()
		if legacy_profile is Dictionary:
			var migrated_profile: Dictionary = BuildDocumentScript.from_legacy_skin_profile(legacy_profile, document)
			if not migrated_profile.is_empty():
				document = migrated_profile
				if not BuildDocumentStoreScript.save_document(document, BUILD_DOCUMENT_PATH):
					push_warning("Legacy skin profile was imported in memory but canonical BuildDocument save failed; original profile retained.")
				else:
					print("Legacy skin profile migrated into canonical BuildDocument; original profile retained.")
			else:
				push_warning("Legacy skin profile failed validation or was already migrated; original profile retained.")
		else:
			push_warning("Legacy skin profile is not a valid JSON object; original profile retained.")

	return document

func _save_build_document() -> bool:
	if not BuildDocumentScript.validate(_build_document).get("ok", false):
		push_warning("BuildDocument validation failed; save was refused.")
		return false
	var next_revision := int(_build_document.get("revision", 0)) + 1
	var candidate := _build_document.duplicate(true)
	candidate["revision"] = next_revision
	if not BuildDocumentStoreScript.save_document(candidate, BUILD_DOCUMENT_PATH):
		return false
	_build_document["revision"] = next_revision
	_refresh_build_summary()
	return true


func _refresh_build_summary() -> void:
	if not is_instance_valid(_build_summary_label):
		return
	var vehicle: Dictionary = _build_document.get("vehicle", {})
	var customization: Dictionary = _build_document.get("customization", {})
	var materials: Array = customization.get("materials", [])
	var paint_color := "—"
	if is_instance_valid(_bike) and _selected_part_id in _bike.get_part_ids():
		paint_color = "#" + _bike.get_part_color(_selected_part_id).to_html(false).to_upper()
	var assembly_mode := str(_build_document.get("assembly", {}).get("mode", "stock")).to_upper()
	var neon_state := "ON" if bool(_build_document.get("render", {}).get("neon_enabled", true)) else "OFF"
	_build_summary_label.text = "BUILD  /  %s\nREVISION  /  %s\nPART  /  %s\nPAINT  /  %s\nMATERIAL RECORDS  /  %d\nASSEMBLY  /  %s\nNEON  /  %s" % [str(vehicle.get("display_name", "Unassigned vehicle")), str(_build_document.get("revision", 1)), _selected_part_id.replace("_", " ").to_upper(), paint_color, materials.size(), assembly_mode, neon_state]

func get_build_document_snapshot() -> Dictionary:
	return _build_document.duplicate(true)

func save_project() -> bool:
	return _save_build_document()
