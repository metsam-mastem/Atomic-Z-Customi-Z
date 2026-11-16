extends Node
class_name QualityController

signal quality_tier_changed(tier: String, measured_fps: float)

const SAMPLE_WINDOW_SECONDS := 2.0
const LOW_FPS_THRESHOLD := 28.0
const HIGH_FPS_THRESHOLD := 48.0
const LOW_WINDOWS_TO_REDUCE := 2
const HIGH_WINDOWS_TO_RESTORE := 4

const QUALITY_TIER := "quality"
const PERFORMANCE_TIER := "performance"

var _light: DirectionalLight3D
var _sample_time := 0.0
var _sample_frames := 0
var _low_samples := 0
var _high_samples := 0
var _reduced := false
var _last_measured_fps := 0.0

func configure(key_light: DirectionalLight3D) -> void:
	_light = key_light
	_apply_quality_state()

func _process(delta: float) -> void:
	record_frame(delta)

## Public deterministic input used by the runtime and headless contract tests.
## A long pause is discarded so app resume time is not misread as poor FPS.
func record_frame(delta: float) -> void:
	if delta <= 0.0:
		return
	if delta > SAMPLE_WINDOW_SECONDS:
		_reset_partial_window()
		return

	_sample_time += delta
	_sample_frames += 1
	if _sample_time + 0.000001 < SAMPLE_WINDOW_SECONDS:
		return

	_last_measured_fps = float(_sample_frames) / _sample_time
	_reset_partial_window()
	_update_hysteresis(_last_measured_fps)

func get_quality_tier() -> String:
	return PERFORMANCE_TIER if _reduced else QUALITY_TIER

func is_reduced_quality() -> bool:
	return _reduced

func get_last_measured_fps() -> float:
	return _last_measured_fps

func get_last_frame_time_ms() -> float:
	if _last_measured_fps <= 0.0:
		return 0.0
	return 1000.0 / _last_measured_fps

## Clears accumulated samples and restores the default tier.
func reset_adaptive_state() -> void:
	_reset_partial_window()
	_low_samples = 0
	_high_samples = 0
	_last_measured_fps = 0.0
	_set_reduced_quality(false)

func _update_hysteresis(fps: float) -> void:
	if fps < LOW_FPS_THRESHOLD:
		_low_samples += 1
		_high_samples = 0
	elif fps > HIGH_FPS_THRESHOLD:
		_high_samples += 1
		_low_samples = 0
	else:
		_low_samples = 0
		_high_samples = 0

	if _low_samples >= LOW_WINDOWS_TO_REDUCE and not _reduced:
		_set_reduced_quality(true)
	elif _high_samples >= HIGH_WINDOWS_TO_RESTORE and _reduced:
		_set_reduced_quality(false)

func _set_reduced_quality(enabled: bool) -> void:
	if _reduced == enabled:
		return
	_reduced = enabled
	_apply_quality_state()
	quality_tier_changed.emit(get_quality_tier(), _last_measured_fps)

func _apply_quality_state() -> void:
	if is_instance_valid(_light):
		_light.shadow_enabled = not _reduced

func _reset_partial_window() -> void:
	_sample_time = 0.0
	_sample_frames = 0
