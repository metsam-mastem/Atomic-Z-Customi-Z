extends Node
class_name QualityController

var _light: DirectionalLight3D
var _sample_time := 0.0
var _sample_frames := 0
var _low_samples := 0
var _high_samples := 0
var _reduced := false

func configure(key_light: DirectionalLight3D) -> void:
	_light = key_light

func _process(delta: float) -> void:
	_sample_time += delta
	_sample_frames += 1
	if _sample_time < 2.0:
		return
	var fps := float(_sample_frames) / _sample_time
	_sample_time = 0.0
	_sample_frames = 0
	if fps < 28.0:
		_low_samples += 1
		_high_samples = 0
	elif fps > 48.0:
		_high_samples += 1
		_low_samples = 0
	else:
		_low_samples = 0
		_high_samples = 0
	if _low_samples >= 2 and not _reduced:
		_set_reduced_quality(true)
	elif _high_samples >= 4 and _reduced:
		_set_reduced_quality(false)

func _set_reduced_quality(enabled: bool) -> void:
	_reduced = enabled
	if is_instance_valid(_light):
		_light.shadow_enabled = not enabled
