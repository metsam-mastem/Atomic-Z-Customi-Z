extends Node3D
class_name NeonSkin

const DEFAULT_CONFIG := "res://neon_skin_config.json"
const X_MIN := 100.0
const X_MAX := 600.0
const Y_MIN := 280.0
const Y_MAX := 480.0
const WORLD_X_MIN := -1.4
const WORLD_X_MAX := 1.4
const WORLD_Y_MIN := 0.35
const WORLD_Y_MAX := 1.55
const SIDE_Z := 0.30

var _config: Dictionary = {}
var _segments: Dictionary = {}
var _ordered_ids: Array[String] = []
var _palette: Dictionary = {}
var _glow_intensity := 0.8
var _skin_visible := true

func _ready() -> void:
	if not load_skin(DEFAULT_CONFIG):
		push_warning("Neon skin config could not be loaded; neon overlay remains empty.")

func load_skin(path: String) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("Cannot open neon skin config: " + path)
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not _validate_config(parsed):
		push_warning("Neon skin config failed validation: " + path)
		return false

	_config = parsed
	_palette = {
		"primary": Color.from_string(str(_config["colors"]["primary"]), Color.WHITE),
		"secondary": Color.from_string(str(_config["colors"]["secondary"]), Color.WHITE)
	}
	_glow_intensity = float(_config["colors"]["glow_intensity"])
	_rebuild_segments()
	return true

func get_segment_ids() -> Array[String]:
	return _ordered_ids.duplicate()

func get_glow_intensity() -> float:
	return _glow_intensity

func is_segment_visible(segment_id: String) -> bool:
	if not _segments.has(segment_id):
		return false
	return bool(_segments[segment_id]["visible"])

func save_skin(path: String = "user://neon_skin_config.json") -> bool:
	if _config.is_empty():
		return false
	var colors: Dictionary = _config["colors"]
	colors["primary"] = "#" + _palette["primary"].to_html(false).to_upper()
	colors["secondary"] = "#" + _palette["secondary"].to_html(false).to_upper()
	colors["glow_intensity"] = _glow_intensity
	for segment in _config["line_segments"]:
		var segment_id := str(segment["id"])
		segment["visible"] = bool(_segments[segment_id]["visible"])
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(_config, "\t"))
	file.close()
	return true

func get_segment_color(segment_id: String) -> Color:
	if not _segments.has(segment_id):
		return Color.TRANSPARENT
	return _palette[_segments[segment_id]["color"]]

func set_segment_visible(segment_id: String, visible: bool) -> bool:
	if not _segments.has(segment_id):
		return false
	_segments[segment_id]["visible"] = visible
	for child in _segments[segment_id]["nodes"]:
		child.visible = visible and _skin_visible
	return true

func set_skin_visible(visible: bool) -> void:
	_skin_visible = visible
	for segment_id in _ordered_ids:
		for child in _segments[segment_id]["nodes"]:
			child.visible = visible and _segments[segment_id]["visible"]

func set_glow_intensity(value: float) -> void:
	_glow_intensity = clampf(value, 0.0, 1.0)
	for segment_id in _ordered_ids:
		_build_segment_visuals(segment_id)

func set_palette_color(key: String, color: Color) -> bool:
	if not _palette.has(key):
		return false
	_palette[key] = color
	for segment_id in _ordered_ids:
		if _segments[segment_id]["color"] == key:
			_build_segment_visuals(segment_id)
	return true

func _validate_config(value: Variant) -> bool:
	if not (value is Dictionary):
		return false
	var data: Dictionary = value
	if not data.has("bike_model") or not data.has("skin_name"):
		return false
	if not data.has("colors") or not (data["colors"] is Dictionary):
		return false
	var colors: Dictionary = data["colors"]
	for key in ["primary", "secondary"]:
		if not colors.has(key) or not _is_valid_hex(str(colors[key])):
			return false
	if not colors.has("glow_intensity") or not (colors["glow_intensity"] is int or colors["glow_intensity"] is float):
		return false
	if float(colors["glow_intensity"]) < 0.0 or float(colors["glow_intensity"]) > 1.0:
		return false
	if not data.has("line_segments") or not (data["line_segments"] is Array) or data["line_segments"].is_empty():
		return false

	var seen: Dictionary = {}
	for segment in data["line_segments"]:
		if not (segment is Dictionary):
			return false
		if not segment.has("id") or str(segment["id"]).strip_edges().is_empty():
			return false
		var segment_id := str(segment["id"])
		if seen.has(segment_id):
			return false
		seen[segment_id] = true
		if not segment.has("color") or not (str(segment["color"]) in ["primary", "secondary"]):
			return false
		if segment.has("visible") and not (segment["visible"] is bool):
			return false
		if not segment.has("width") or not (segment["width"] is int or segment["width"] is float):
			return false
		if float(segment["width"]) <= 0.0 or float(segment["width"]) > 40.0:
			return false
		if not segment.has("points") or not (segment["points"] is Array) or segment["points"].size() < 2:
			return false
		for point in segment["points"]:
			if not (point is Array) or point.size() != 2:
				return false
			if not (point[0] is int or point[0] is float) or not (point[1] is int or point[1] is float):
				return false
			if float(point[0]) < 0.0 or float(point[0]) > 800.0 or float(point[1]) < 0.0 or float(point[1]) > 600.0:
				return false
	return true

func _is_valid_hex(value: String) -> bool:
	var regex := RegEx.new()
	regex.compile("^#[0-9A-Fa-f]{6}([0-9A-Fa-f]{2})?$")
	return regex.search(value) != null

func _rebuild_segments() -> void:
	for child in get_children():
		child.queue_free()
	_segments.clear()
	_ordered_ids.clear()
	for segment in _config["line_segments"]:
		var segment_id := str(segment["id"])
		_ordered_ids.append(segment_id)
		_segments[segment_id] = {
			"points": segment["points"],
			"width": float(segment["width"]),
			"color": str(segment["color"]),
			"visible": bool(segment.get("visible", true)),
			"nodes": []
		}
		_build_segment_visuals(segment_id)

func _build_segment_visuals(segment_id: String) -> void:
	if not _segments.has(segment_id):
		return
	var segment: Dictionary = _segments[segment_id]
	for old_node in segment["nodes"]:
		if is_instance_valid(old_node):
			old_node.queue_free()
	segment["nodes"] = []
	var color: Color = _palette[segment["color"]]
	var energy := 0.5 + _glow_intensity * 4.0
	var passes := [
		{"width": 3.6, "alpha": 0.10 * _glow_intensity, "z": 0.0},
		{"width": 2.0, "alpha": 0.22 * _glow_intensity, "z": 0.001},
		{"width": 1.0, "alpha": 1.0, "z": 0.002}
	]
	for pass_data in passes:
		var material := StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color = Color(color.r, color.g, color.b, float(pass_data["alpha"]))
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = energy
		var mesh := ImmediateMesh.new()
		mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES, material)
		_append_ribbon(mesh, segment["points"], float(segment["width"]) * float(pass_data["width"]) * 0.0028, float(pass_data["z"]))
		mesh.surface_end()
		var visual := MeshInstance3D.new()
		visual.name = segment_id + "_glow_" + str(segment["width"])
		visual.mesh = mesh
		visual.visible = bool(segment["visible"]) and _skin_visible
		add_child(visual)
		segment["nodes"].append(visual)
	_segments[segment_id] = segment

func _append_ribbon(mesh: ImmediateMesh, points: Array, half_width: float, z_offset: float) -> void:
	for index in range(points.size() - 1):
		var a := _map_point(points[index])
		var b := _map_point(points[index + 1])
		var direction := Vector2(b.x - a.x, b.y - a.y)
		if direction.length_squared() < 0.000001:
			continue
		var normal := Vector2(-direction.y, direction.x).normalized() * half_width
		var a_left := Vector3(a.x + normal.x, a.y + normal.y, SIDE_Z + z_offset)
		var a_right := Vector3(a.x - normal.x, a.y - normal.y, SIDE_Z + z_offset)
		var b_left := Vector3(b.x + normal.x, b.y + normal.y, SIDE_Z + z_offset)
		var b_right := Vector3(b.x - normal.x, b.y - normal.y, SIDE_Z + z_offset)
		mesh.surface_add_vertex(a_left)
		mesh.surface_add_vertex(a_right)
		mesh.surface_add_vertex(b_left)
		mesh.surface_add_vertex(b_left)
		mesh.surface_add_vertex(a_right)
		mesh.surface_add_vertex(b_right)

func _map_point(point: Array) -> Vector2:
	var x_ratio := (float(point[0]) - X_MIN) / (X_MAX - X_MIN)
	var y_ratio := (float(point[1]) - Y_MIN) / (Y_MAX - Y_MIN)
	return Vector2(
		lerpf(WORLD_X_MIN, WORLD_X_MAX, x_ratio),
		lerpf(WORLD_Y_MAX, WORLD_Y_MIN, y_ratio)
	)
