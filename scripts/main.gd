extends Node3D

const BikeAssemblyScript = preload("res://scripts/bike_assembly.gd")
const QualityControllerScript = preload("res://scripts/quality_controller.gd")
const NeonSkinScript = preload("res://scripts/neon_skin.gd")
const BuildDocumentScript = preload("res://scripts/build_document.gd")
const BuildDocumentStoreScript = preload("res://scripts/build_document_store.gd")

var _bike
var _camera: Camera3D
var _key_light: DirectionalLight3D
var _quality
var _neon_skin
var _build_document: Dictionary = {}
var _part_selector: OptionButton
var _paint_picker: ColorPickerButton
var _build_summary_label: Label
var _assembly_button: Button
var _neon_toggle_button: Button
var _neon_editor_controls: Array[Control] = []
var _disclaimer_label: Label
var _file_dialog: FileDialog
var _asset_metadata_dialog: ConfirmationDialog
var _asset_license_input: LineEdit
var _asset_source_input: LineEdit
var _pending_asset_source_path := ""
var _selected_part_id := "fuel_tank"
const BUILD_DOCUMENT_PATH := "user://atomic_z_build.json"
var _orbit_angle := 0.0
var _orbit_pitch := 0.16
var _orbit_distance := 5.3
var _dragging := false
var _last_pointer := Vector2.ZERO

func _ready() -> void:
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
	_neon_skin.visible = not _bike.is_imported_model()
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
	hint.text = "DRAG TO ORBIT  •  WHEEL TO ZOOM"
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

	_assembly_button = Button.new()
	_assembly_button.text = "EXPLODED / STOCK" if _bike.supports_exploded_view() else "EXPLODED VIEW N/A"
	_assembly_button.disabled = not _bike.supports_exploded_view()
	_assembly_button.pressed.connect(_on_toggle_assembly)
	controls.add_child(_assembly_button)

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

	_neon_toggle_button = Button.new()
	_neon_toggle_button.text = "NEON ON / OFF"
	_neon_toggle_button.toggle_mode = true
	_neon_toggle_button.button_pressed = bool(_build_document.get("render", {}).get("neon_enabled", true))
	_neon_toggle_button.disabled = _bike.is_imported_model()
	_neon_toggle_button.tooltip_text = "Neon preview stays disabled until paths are verified against imported GLB surfaces." if _bike.is_imported_model() else "Toggle neon preview"
	_neon_toggle_button.toggled.connect(_on_neon_toggled)
	controls.add_child(_neon_toggle_button)

	var skin_controls := HBoxContainer.new()
	skin_controls.position = Vector2(24.0, 146.0)
	skin_controls.add_theme_constant_override("separation", 10)
	root.add_child(skin_controls)

	var import_glb_button := Button.new()
	import_glb_button.text = "IMPORT GLB"
	import_glb_button.tooltip_text = "Import a local glTF Binary asset and generate a stable surface catalog"
	import_glb_button.pressed.connect(_on_import_glb_pressed)
	skin_controls.add_child(import_glb_button)

	_add_neon_segment_toggle(skin_controls, "TAIL", "tail_underglow")
	_add_neon_segment_toggle(skin_controls, "TANK", "tank_accent")
	_add_neon_segment_toggle(skin_controls, "LOWER", "lower_fairing")

	var palette: Dictionary = _build_document.get("customization", {}).get("palette", {})
	var primary_picker := ColorPickerButton.new()
	primary_picker.name = "NeonPrimaryPicker"
	primary_picker.color = Color.from_string(str(palette.get("primary", "#00FFCC")), Color("#00FFCC"))
	primary_picker.custom_minimum_size = Vector2(42.0, 42.0)
	primary_picker.tooltip_text = "Neon primary color"
	primary_picker.disabled = _bike.is_imported_model()
	primary_picker.color_changed.connect(_on_neon_primary_changed)
	skin_controls.add_child(primary_picker)
	_neon_editor_controls.append(primary_picker)

	var secondary_picker := ColorPickerButton.new()
	secondary_picker.name = "NeonSecondaryPicker"
	secondary_picker.color = Color.from_string(str(palette.get("secondary", "#FF00FF")), Color("#FF00FF"))
	secondary_picker.custom_minimum_size = Vector2(42.0, 42.0)
	secondary_picker.tooltip_text = "Neon secondary color"
	secondary_picker.disabled = _bike.is_imported_model()
	secondary_picker.color_changed.connect(_on_neon_secondary_changed)
	skin_controls.add_child(secondary_picker)
	_neon_editor_controls.append(secondary_picker)

	var glow_slider := HSlider.new()
	glow_slider.name = "NeonGlowSlider"
	glow_slider.custom_minimum_size = Vector2(120.0, 32.0)
	glow_slider.min_value = 0.0
	glow_slider.max_value = 1.0
	glow_slider.step = 0.05
	glow_slider.value = float(_build_document.get("render", {}).get("glow_intensity", 0.8))
	glow_slider.tooltip_text = "Neon glow intensity"
	glow_slider.editable = not _bike.is_imported_model()
	glow_slider.value_changed.connect(_on_glow_changed)
	skin_controls.add_child(glow_slider)
	_neon_editor_controls.append(glow_slider)

	var save_skin_button := Button.new()
	save_skin_button.text = "SAVE PROJECT"
	save_skin_button.pressed.connect(_on_save_neon_skin)
	skin_controls.add_child(save_skin_button)

	_disclaimer_label = Label.new()
	_disclaimer_label.text = "IMPORTED GLB PREVIEW — NOT FACTORY CAD / NEON UV MAPPING PENDING / NOT ENGINEERING-VALIDATED" if _bike.is_imported_model() else "CONCEPT PLACEHOLDER — NOT FACTORY CAD / NOT ENGINEERING-VALIDATED"
	_disclaimer_label.anchor_left = 0.0
	_disclaimer_label.anchor_top = 1.0
	_disclaimer_label.anchor_right = 1.0
	_disclaimer_label.anchor_bottom = 1.0
	_disclaimer_label.offset_left = 24.0
	_disclaimer_label.offset_top = -34.0
	_disclaimer_label.offset_right = -24.0
	_disclaimer_label.offset_bottom = -10.0
	_disclaimer_label.add_theme_font_size_override("font_size", 11)
	_disclaimer_label.modulate = Color("#aab8c8")
	root.add_child(_disclaimer_label)

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
	segment_button.disabled = _bike.is_imported_model()
	segment_button.toggled.connect(_on_neon_segment_toggled.bind(segment_id))
	parent.add_child(segment_button)
	_neon_editor_controls.append(segment_button)

func _on_neon_segment_toggled(enabled: bool, segment_id: String) -> void:
	if _bike.is_imported_model():
		return
	if is_instance_valid(_neon_skin):
		_neon_skin.set_segment_visible(segment_id, enabled)

func _on_neon_primary_changed(color: Color) -> void:
	if _bike.is_imported_model():
		return
	if is_instance_valid(_neon_skin):
		_neon_skin.set_palette_color("primary", color)

func _on_neon_secondary_changed(color: Color) -> void:
	if _bike.is_imported_model():
		return
	if is_instance_valid(_neon_skin):
		_neon_skin.set_palette_color("secondary", color)

func _on_neon_toggled(enabled: bool) -> void:
	if _bike.is_imported_model():
		return
	if is_instance_valid(_neon_skin):
		_neon_skin.set_skin_visible(enabled)

func _on_glow_changed(value: float) -> void:
	if _bike.is_imported_model():
		return
	if is_instance_valid(_neon_skin):
		_neon_skin.set_glow_intensity(value)

func _on_import_glb_pressed() -> void:
	if _file_dialog == null:
		_file_dialog = FileDialog.new()
		_file_dialog.title = "Select a motorcycle GLB"
		_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
		_file_dialog.use_native_dialog = OS.get_name() == "Android"
		_file_dialog.add_filter("*.glb", "glTF Binary models")
		_file_dialog.file_selected.connect(_on_glb_file_selected)
		add_child(_file_dialog)
	_file_dialog.popup_centered_ratio(0.82)

func _on_glb_file_selected(path: String) -> void:
	if not path.to_lower().ends_with(".glb"):
		push_warning("Only binary glTF (.glb) models are supported.")
		return
	_pending_asset_source_path = path
	_show_asset_metadata_dialog()

func _show_asset_metadata_dialog() -> void:
	if _asset_metadata_dialog == null:
		_asset_metadata_dialog = ConfirmationDialog.new()
		_asset_metadata_dialog.title = "Asset provenance"
		_asset_metadata_dialog.dialog_text = "Record the model license and original source. An unknown or missing license must not be represented as open-source."
		var fields := VBoxContainer.new()
		fields.add_theme_constant_override("separation", 8)
		var license_label := Label.new()
		license_label.text = "License identifier"
		fields.add_child(license_label)
		_asset_license_input = LineEdit.new()
		_asset_license_input.placeholder_text = "Example: CC0-1.0, MIT, or author-provided terms"
		_asset_license_input.custom_minimum_size.x = 420.0
		fields.add_child(_asset_license_input)
		var source_label := Label.new()
		source_label.text = "Original source URL or provenance record"
		fields.add_child(source_label)
		_asset_source_input = LineEdit.new()
		_asset_source_input.placeholder_text = "https://... or author / original source details"
		_asset_source_input.custom_minimum_size.x = 420.0
		fields.add_child(_asset_source_input)
		_asset_metadata_dialog.add_child(fields)
		_asset_metadata_dialog.confirmed.connect(_on_asset_metadata_confirmed)
		add_child(_asset_metadata_dialog)
	_asset_license_input.text = ""
	_asset_source_input.text = ""
	_asset_metadata_dialog.popup_centered(Vector2i(560, 260))

func _on_asset_metadata_confirmed() -> void:
	var license_id := _asset_license_input.text.strip_edges()
	var source_record := _asset_source_input.text.strip_edges()
	if license_id.is_empty() or source_record.is_empty():
		push_warning("Import cancelled: license and source provenance are required.")
		_asset_metadata_dialog.popup_centered(Vector2i(560, 260))
		return
	await _install_selected_glb(license_id, source_record)

func _install_selected_glb(license_id: String, source_record: String) -> void:
	var source_file := FileAccess.open(_pending_asset_source_path, FileAccess.READ)
	if source_file == null:
		push_warning("Could not read the selected GLB. On Android, use the system file picker and grant access to the file.")
		return
	var file_size := source_file.get_length()
	if file_size < 20 or file_size > 268435456:
		source_file.close()
		push_warning("GLB file size is invalid or exceeds the 256 MiB import limit.")
		return
	var model_bytes := source_file.get_buffer(file_size)
	var read_error := source_file.get_error()
	source_file.close()
	if read_error != OK or model_bytes.size() != file_size or model_bytes.slice(0, 4).get_string_from_ascii() != "glTF":
		push_warning("Selected file is not a readable binary glTF asset.")
		return

	var directory_path := "user://vehicle_assets"
	var directory_error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory_path))
	if directory_error != OK and directory_error != ERR_ALREADY_EXISTS:
		push_warning("Could not create the local vehicle asset folder: " + error_string(directory_error))
		return

	var temporary_path := directory_path + "/incoming.glb.tmp"
	var output_file := FileAccess.open(temporary_path, FileAccess.WRITE)
	if output_file == null:
		push_warning("Could not stage the selected GLB in app storage.")
		return
	output_file.store_buffer(model_bytes)
	output_file.flush()
	var write_error := output_file.get_error()
	output_file.close()
	if write_error != OK:
		_remove_asset_file(temporary_path)
		push_warning("Failed to copy the selected GLB into app storage.")
		return

	var asset_hash := FileAccess.get_sha256(temporary_path).to_lower()
	if asset_hash.length() != 64:
		_remove_asset_file(temporary_path)
		push_warning("Could not calculate the selected GLB SHA-256.")
		return
	var installed_path := directory_path + "/asset_" + asset_hash.substr(0, 16) + ".glb"
	if FileAccess.file_exists(installed_path):
		_remove_asset_file(temporary_path)
	else:
		var rename_error := DirAccess.rename_absolute(
			ProjectSettings.globalize_path(temporary_path),
			ProjectSettings.globalize_path(installed_path)
		)
		if rename_error != OK:
			_remove_asset_file(temporary_path)
			push_warning("Could not finalize the copied GLB: " + error_string(rename_error))
			return

	var candidate_document := _build_document.duplicate(true)
	var previous_asset: Dictionary = candidate_document.get("asset", {}).duplicate(true)
	var previous_hash := str(previous_asset.get("sha256", ""))
	var previous_catalog: Array = previous_asset.get("surface_catalog", [])
	var preserved_surface_materials: Array = []
	var active_materials: Array = candidate_document.get("customization", {}).get("materials", []).duplicate(true)
	for material_value in active_materials:
		if material_value is Dictionary and material_value.has("target_surface_ids"):
			preserved_surface_materials.append(material_value.duplicate(true))
	if not preserved_surface_materials.is_empty():
		var extensions: Array = candidate_document.get("extensions", []).duplicate(true)
		extensions.append({
			"extension_id": "replaced_asset_surface_materials",
			"schema_version": 1,
			"status": "preserved_unmapped",
			"source_asset_sha256": previous_hash,
			"payload": {
				"surface_catalog": previous_catalog.duplicate(true),
				"materials": preserved_surface_materials
			}
		})
		candidate_document["extensions"] = extensions
		var retained_materials: Array = []
		for material_value in active_materials:
			if not (material_value is Dictionary) or not material_value.has("target_surface_ids"):
				retained_materials.append(material_value)
		candidate_document["customization"]["materials"] = retained_materials

	var candidate_asset: Dictionary = previous_asset
	candidate_asset["uri"] = installed_path
	candidate_asset["sha256"] = asset_hash
	candidate_asset["license"] = license_id
	candidate_asset["source"] = source_record
	candidate_asset["validation_status"] = "local_import_pending_review"
	candidate_asset["surface_catalog"] = []
	candidate_document["asset"] = candidate_asset
	if not BuildDocumentScript.validate(candidate_document).get("ok", false):
		push_warning("The imported asset metadata did not produce a valid BuildDocument.")
		return

	var candidate_bike := BikeAssemblyScript.new()
	candidate_bike.name = "ImportedMotorcycle"
	candidate_bike.configure_build_document(candidate_document)
	add_child(candidate_bike)
	await process_frame
	if not candidate_bike.is_imported_model():
		candidate_bike.queue_free()
		push_warning("GLB import was rejected. The existing garage model remains active; inspect the output warnings for details.")
		return

	var previous_bike = _bike
	_bike = candidate_bike
	_build_document = candidate_document
	_selected_part_id = ""
	_populate_part_selector()
	if _part_selector.item_count > 0:
		_paint_picker.color = _bike.get_part_color(_selected_part_id)
	if is_instance_valid(previous_bike):
		previous_bike.queue_free()
	_update_imported_model_controls()
	_refresh_build_summary()
	if not _save_build_document():
		push_warning("GLB loaded successfully but the BuildDocument save failed. Use SAVE PROJECT after checking app storage.")

func _update_imported_model_controls() -> void:
	if is_instance_valid(_neon_skin):
		_neon_skin.visible = false
	if is_instance_valid(_assembly_button):
		_assembly_button.text = "EXPLODED VIEW N/A"
		_assembly_button.disabled = true
	if is_instance_valid(_neon_toggle_button):
		_neon_toggle_button.disabled = true
		_neon_toggle_button.tooltip_text = "Neon preview is disabled until its paths are mapped to verified GLB surfaces."
	for control in _neon_editor_controls:
		if is_instance_valid(control):
			control.set("disabled", true) if control is Button or control is ColorPickerButton else control.set("editable", false)
	if is_instance_valid(_disclaimer_label):
		_disclaimer_label.text = "IMPORTED GLB PREVIEW — NOT FACTORY CAD / UV MAPPING PENDING / NOT ENGINEERING-VALIDATED"

func _remove_asset_file(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _on_save_neon_skin() -> void:
	if not _save_build_document():
		push_warning("Could not save the unified build document.")
	else:
		_refresh_build_summary()

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
