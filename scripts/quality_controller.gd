extends Node
class_name QualityController

const SAMPLE_INTERVAL_SECONDS := 2.0
const LOW_FPS_THRESHOLD := 28.0
const HIGH_FPS_THRESHOLD := 48.0
const LOW_SAMPLES_TO_REDUCE := 2
const HIGH_SAMPLES_TO_RESTORE := 4

var _light: DirectionalLight3D
var _sample_time := 0.0
var _sample_frames := 0
var _low_samples := 0
var _high_samples := 0
var _reduced := false

func configure(key_light: DirectionalLight3D) -> void:
	_light = key_light
	_apply_quality_to_light()

func is_reduced_quality() -> bool:
	return _reduced

# Public sampling entry point keeps the policy deterministic and testable.
func submit_fps_sample(fps: float) -> void:
	if not is_finite(fps) or fps <= 0.0:
		return

	if fps < LOW_FPS_THRESHOLD:
		_low_samples = mini(_low_samples + 1, LOW_SAMPLES_TO_REDUCE)
		_high_samples = 0
	elif fps > HIGH_FPS_THRESHOLD:
		_high_samples = mini(_high_samples + 1, HIGH_SAMPLES_TO_RESTORE)
		_low_samples = 0
	else:
		# The neutral band deliberately resets both counters to avoid oscillation.
		_low_samples = 0
		_high_samples = 0

	if _low_samples >= LOW_SAMPLES_TO_REDUCE and not _reduced:
		_set_reduced_quality(true)
	elif _high_samples >= HIGH_SAMPLES_TO_RESTORE and _reduced:
		_set_reduced_quality(false)

func _process(delta: float) -> void:
	if delta <= 0.0:
		return
	_sample_time += delta
	_sample_frames += 1
	if _sample_time < SAMPLE_INTERVAL_SECONDS:
		return

	var fps := float(_sample_frames) / _sample_time
	_sample_time = 0.0
	_sample_frames = 0
	submit_fps_sample(fps)

func _set_reduced_quality(enabled: bool) -> void:
	if _reduced == enabled:
		return
	_reduced = enabled
	_apply_quality_to_light()

func _apply_quality_to_light() -> void:
	if is_instance_valid(_light):
		_light.shadow_enabled = not _reduced
