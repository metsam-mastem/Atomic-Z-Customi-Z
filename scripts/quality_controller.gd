extends Node
class_name QualityController

signal quality_tier_changed(tier: String, measured_fps: float)

const SAMPLE_INTERVAL_SECONDS := 2.0
const LOW_FPS_THRESHOLD := 28.0
const HIGH_FPS_THRESHOLD := 48.0
const LOW_SAMPLES_TO_REDUCE := 2
const HIGH_SAMPLES_TO_RESTORE := 4
const QUALITY_TIER := "quality"
const PERFORMANCE_TIER := "performance"

var _light: DirectionalLight3D
var _sample_time := 0.0
var _sample_frames := 0
var _low_samples := 0
var _high_samples := 0
var _last_measured_fps := 0.0
var _reduced := false

func configure(key_light: DirectionalLight3D) -> void:
	_light = key_light
	_apply_quality_to_light()

func is_reduced_quality() -> bool:
	return _reduced

func get_quality_tier() -> String:
	return PERFORMANCE_TIER if _reduced else QUALITY_TIER

func get_last_measured_fps() -> float:
	return _last_measured_fps

func get_last_frame_time_ms() -> float:
	if _last_measured_fps <= 0.0:
		return 0.0
	return 1000.0 / _last_measured_fps

# Runtime entry point. A long delta (for example, app suspension) is discarded
# so resume time is never mistaken for low frame rate.
func record_frame(delta: float) -> void:
	if not is_finite(delta) or delta <= 0.0:
		return
	if delta > SAMPLE_INTERVAL_SECONDS:
		_reset_partial_window()
		_low_samples = 0
		_high_samples = 0
		return

	_sample_time += delta
	_sample_frames += 1
	if _sample_time + 0.000001 < SAMPLE_INTERVAL_SECONDS:
		return

	_last_measured_fps = float(_sample_frames) / _sample_time
	_reset_partial_window()
	_update_hysteresis(_last_measured_fps)

# Explicit sample input keeps threshold behavior deterministic in contract tests
# and allows other runtime diagnostics to submit a completed measurement window.
func submit_fps_sample(fps: float) -> void:
	if not is_finite(fps) or fps <= 0.0:
		return
	_last_measured_fps = fps
	_update_hysteresis(fps)

func reset_adaptive_state() -> void:
	_reset_partial_window()
	_low_samples = 0
	_high_samples = 0
	_last_measured_fps = 0.0
	_set_reduced_quality(false)

func _process(delta: float) -> void:
	record_frame(delta)

func _update_hysteresis(fps: float) -> void:
	if fps < LOW_FPS_THRESHOLD:
		_low_samples = mini(_low_samples + 1, LOW_SAMPLES_TO_REDUCE)
		_high_samples = 0
	elif fps > HIGH_FPS_THRESHOLD:
		_high_samples = mini(_high_samples + 1, HIGH_SAMPLES_TO_RESTORE)
		_low_samples = 0
	else:
		_low_samples = 0
		_high_samples = 0

	if _low_samples >= LOW_SAMPLES_TO_REDUCE and not _reduced:
		_set_reduced_quality(true)
	elif _high_samples >= HIGH_SAMPLES_TO_RESTORE and _reduced:
		_set_reduced_quality(false)

func _set_reduced_quality(enabled: bool) -> void:
	if _reduced == enabled:
		return
	_reduced = enabled
	_apply_quality_to_light()
	quality_tier_changed.emit(get_quality_tier(), _last_measured_fps)

func _apply_quality_to_light() -> void:
	if is_instance_valid(_light):
		_light.shadow_enabled = not _reduced

func _reset_partial_window() -> void:
	_sample_time = 0.0
	_sample_frames = 0
