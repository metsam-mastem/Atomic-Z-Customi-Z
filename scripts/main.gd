extends Node3D

const BikeAssemblyScript = preload("res://scripts/bike_assembly.gd")
const QualityControllerScript = preload("res://scripts/quality_controller.gd")
const NeonSkinScript = preload("res://scripts/neon_skin.gd")

var _bike
var _camera: Camera3D
var _key_light: DirectionalLight3D
var _quality
var _neon_skin
var _orbit_angle := 0.0
var _orbit_pitch := 0.16
var _orbit_distance := 5.3
var _dragging := false
var _last_pointer := Vector2.ZERO

func _ready() -> void:
	_build_world()
	_bike = BikeAssemblyScript.new()
	_bike.name = "MotorcyclePlaceholder"
	add_child(_bike)
	_quality = QualityControllerScript.new()
	add_child(_quality)
	_quality.configure(_key_light)
	_neon_skin = NeonSkinScript.new()
	_neon_skin.name = "NeonSkinOverlay"
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
	layer.add_child(root)

	var title := Label.new()
	title.text = "ATOMIC Z  /  CUSTOMIZATION LAB"
	title.position = Vector2(24.0, 20.0)
	title.add_theme_font_size_override("font_size", 20)
	root.add_child(title)

	var hint := Label.new()
	hint.text = "DRAG TO ORBIT  •  WHEEL TO ZOOM"
	hint.position = Vector2(24.0, 52.0)
	hint.add_theme_font_size_override("font_size", 12)
	hint.modulate = Color("#aab8c8")
	root.add_child(hint)

	var controls := HBoxContainer.new()
	controls.position = Vector2(24.0, 94.0)
	controls.add_theme_constant_override("separation", 10)
	root.add_child(controls)

	var assembly_button := Button.new()
	assembly_button.text = "EXPLODED / STOCK"
	assembly_button.pressed.connect(_on_toggle_assembly)
	controls.add_child(assembly_button)

	var color_button := ColorPickerButton.new()
	color_button.color = Color("#e53b36")
	color_button.custom_minimum_size = Vector2(54.0, 42.0)
	color_button.color_changed.connect(_on_body_color_changed)
	controls.add_child(color_button)

	var reset_button := Button.new()
	reset_button.text = "RESET CAMERA"
	reset_button.pressed.connect(_on_reset_camera)
	controls.add_child(reset_button)

	var neon_button := Button.new()
	neon_button.text = "NEON ON / OFF"
	neon_button.toggle_mode = true
	neon_button.button_pressed = true
	neon_button.toggled.connect(_on_neon_toggled)
	controls.add_child(neon_button)

	var skin_controls := HBoxContainer.new()
	skin_controls.position = Vector2(24.0, 146.0)
	skin_controls.add_theme_constant_override("separation", 10)
	root.add_child(skin_controls)

	_add_neon_segment_toggle(skin_controls, "TAIL", "tail_underglow")
	_add_neon_segment_toggle(skin_controls, "TANK", "tank_accent")
	_add_neon_segment_toggle(skin_controls, "LOWER", "lower_fairing")

	var primary_picker := ColorPickerButton.new()
	primary_picker.color = Color("#00FFCC")
	primary_picker.custom_minimum_size = Vector2(42.0, 42.0)
	primary_picker.tooltip_text = "Neon primary color"
	primary_picker.color_changed.connect(_on_neon_primary_changed)
	skin_controls.add_child(primary_picker)

	var secondary_picker := ColorPickerButton.new()
	secondary_picker.color = Color("#FF00FF")
	secondary_picker.custom_minimum_size = Vector2(42.0, 42.0)
	secondary_picker.tooltip_text = "Neon secondary color"
	secondary_picker.color_changed.connect(_on_neon_secondary_changed)
	skin_controls.add_child(secondary_picker)

	var glow_slider := HSlider.new()
	glow_slider.custom_minimum_size = Vector2(120.0, 32.0)
	glow_slider.min_value = 0.0
	glow_slider.max_value = 1.0
	glow_slider.step = 0.05
	glow_slider.value = 0.8
	glow_slider.tooltip_text = "Neon glow intensity"
	glow_slider.value_changed.connect(_on_glow_changed)
	skin_controls.add_child(glow_slider)

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

func _on_toggle_assembly() -> void:
	_bike.toggle_exploded()

func _on_body_color_changed(color: Color) -> void:
	_bike.set_body_color(color)

func _add_neon_segment_toggle(parent: Control, label_text: String, segment_id: String) -> void:
	var segment_button := Button.new()
	segment_button.text = label_text
	segment_button.toggle_mode = true
	segment_button.button_pressed = true
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

func _on_reset_camera() -> void:
	_orbit_angle = 0.0
	_orbit_pitch = 0.16
	_orbit_distance = 5.3
	_update_camera()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_dragging = event.pressed
		_last_pointer = event.position
	elif event is InputEventScreenDrag and _dragging:
		_apply_orbit_drag(event.position)
	elif event is InputEventMouseButton:
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

func _apply_orbit_drag(pointer: Vector2) -> void:
	var delta := pointer - _last_pointer
	_last_pointer = pointer
	_orbit_angle -= delta.x * 0.008
	_orbit_pitch = clampf(_orbit_pitch + delta.y * 0.004, -0.12, 0.62)
	_update_camera()

func _update_camera() -> void:
	if not is_instance_valid(_camera):
		return
	var target := Vector3(0.0, 0.92, 0.0)
	var horizontal := cos(_orbit_pitch) * _orbit_distance
	_camera.position = target + Vector3(
		sin(_orbit_angle) * horizontal,
		sin(_orbit_pitch) * _orbit_distance,
		cos(_orbit_angle) * horizontal
	)
	_camera.look_at(target, Vector3.UP)
