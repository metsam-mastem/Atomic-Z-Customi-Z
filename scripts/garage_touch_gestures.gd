extends RefCounted
class_name GarageTouchGestures

const DEFAULT_ORBIT_ANGLE := 0.0
const DEFAULT_ORBIT_PITCH := 0.16
const DEFAULT_ORBIT_DISTANCE := 5.3
const MIN_ORBIT_DISTANCE := 3.0
const MAX_ORBIT_DISTANCE := 8.0
const ORBIT_SENSITIVITY := 0.008
const PAN_SENSITIVITY := 0.004
const PINCH_SENSITIVITY := 0.012

var _orbit_angle := DEFAULT_ORBIT_ANGLE
var _orbit_pitch := DEFAULT_ORBIT_PITCH
var _orbit_distance := DEFAULT_ORBIT_DISTANCE
var _target_offset := Vector3.ZERO
var _touch_points: Dictionary = {}

func handle_event(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.canceled:
			_touch_points.erase(touch.index)
			return
		if touch.pressed:
			_touch_points[touch.index] = touch.position
		else:
			_touch_points.erase(touch.index)
		return

	if not (event is InputEventScreenDrag):
		return
	var drag := event as InputEventScreenDrag
	if not _touch_points.has(drag.index):
		return

	if _touch_points.size() == 1:
		var previous_position: Vector2 = _touch_points[drag.index]
		var delta := drag.position - previous_position
		_orbit_angle -= delta.x * ORBIT_SENSITIVITY
		_orbit_pitch = clampf(_orbit_pitch + delta.y * 0.004, -0.12, 0.62)
		_touch_points[drag.index] = drag.position
		return

	var previous_centroid := _centroid()
	var previous_spread := _spread(previous_centroid)
	_touch_points[drag.index] = drag.position
	var next_centroid := _centroid()
	var next_spread := _spread(next_centroid)
	var centroid_delta := next_centroid - previous_centroid
	var camera_right := Vector3(cos(_orbit_angle), 0.0, -sin(_orbit_angle))
	var camera_up := Vector3(
		-sin(_orbit_angle) * sin(_orbit_pitch),
		cos(_orbit_pitch),
		-cos(_orbit_angle) * sin(_orbit_pitch)
	)
	_target_offset += camera_right * (-centroid_delta.x * PAN_SENSITIVITY)
	_target_offset += camera_up * (centroid_delta.y * PAN_SENSITIVITY)
	_orbit_distance = clampf(
		_orbit_distance + (previous_spread - next_spread) * PINCH_SENSITIVITY,
		MIN_ORBIT_DISTANCE,
		MAX_ORBIT_DISTANCE
	)

func sync_camera_state(orbit_angle: float, orbit_pitch: float, orbit_distance: float, target_offset: Vector3) -> void:
	_orbit_angle = orbit_angle
	_orbit_pitch = clampf(orbit_pitch, -0.12, 0.62)
	_orbit_distance = clampf(orbit_distance, MIN_ORBIT_DISTANCE, MAX_ORBIT_DISTANCE)
	_target_offset = target_offset

func get_camera_state() -> Dictionary:
	return {
		"orbit_angle": _orbit_angle,
		"orbit_pitch": _orbit_pitch,
		"orbit_distance": _orbit_distance,
		"target_offset": _target_offset
	}

func reset() -> void:
	_orbit_angle = DEFAULT_ORBIT_ANGLE
	_orbit_pitch = DEFAULT_ORBIT_PITCH
	_orbit_distance = DEFAULT_ORBIT_DISTANCE
	_target_offset = Vector3.ZERO
	_touch_points.clear()

func _centroid() -> Vector2:
	if _touch_points.is_empty():
		return Vector2.ZERO
	var total := Vector2.ZERO
	for point_value in _touch_points.values():
		var point: Vector2 = point_value
		total += point
	return total / float(_touch_points.size())

func _spread(center: Vector2) -> float:
	if _touch_points.size() < 2:
		return 0.0
	var total := 0.0
	for point_value in _touch_points.values():
		var point: Vector2 = point_value
		total += point.distance_to(center)
	return total / float(_touch_points.size())
