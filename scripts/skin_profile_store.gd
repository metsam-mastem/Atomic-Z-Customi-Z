extends Node
## Shared skin profile persistence and hardware JSON export.
## Register as an Autoload named SkinProfileStore in Project Settings.

signal profile_changed(profile: Dictionary)

const SAVE_PATH := "user://skin_profile.json"
const SCHEMA_VERSION := 1

var primary_color := Color(0.0, 1.0, 0.8, 1.0)
var glow_intensity := 3.0
var pulse_speed := 2.0

func _ready() -> void:
    load_profile()

func set_profile(color: Color, glow: float, pulse: float) -> void:
    primary_color = color
    glow_intensity = clampf(glow, 0.0, 10.0)
    pulse_speed = clampf(pulse, 0.0, 10.0)
    profile_changed.emit(get_profile())

func get_profile() -> Dictionary:
    return {
        "schema_version": SCHEMA_VERSION,
        "color": primary_color.to_html(true),
        "glow_intensity": glow_intensity,
        "pulse_speed": pulse_speed
    }

func save_profile() -> Error:
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        return FileAccess.get_open_error()
    file.store_string(JSON.stringify(get_profile(), "\t"))
    file.close()
    return OK

func load_profile() -> Error:
    if not FileAccess.file_exists(SAVE_PATH):
        return ERR_FILE_NOT_FOUND
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        return FileAccess.get_open_error()
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    file.close()
    if not (parsed is Dictionary):
        return ERR_PARSE_ERROR
    if int(parsed.get("schema_version", -1)) != SCHEMA_VERSION:
        return ERR_INVALID_DATA
    var color_text := str(parsed.get("color", ""))
    if not color_text.begins_with("#") or color_text.length() not in [7, 9]:
        return ERR_INVALID_DATA
    var glow_value: Variant = parsed.get("glow_intensity", null)
    var pulse_value: Variant = parsed.get("pulse_speed", null)
    if not (glow_value is int or glow_value is float):
        return ERR_INVALID_DATA
    if not (pulse_value is int or pulse_value is float):
        return ERR_INVALID_DATA
    var glow := float(glow_value)
    var pulse := float(pulse_value)
    if not is_finite(glow) or not is_finite(pulse):
        return ERR_INVALID_DATA
    if glow < 0.0 or glow > 10.0 or pulse < 0.0 or pulse > 10.0:
        return ERR_INVALID_DATA
    primary_color = Color.from_string(color_text, primary_color)
    glow_intensity = glow
    pulse_speed = pulse
    profile_changed.emit(get_profile())
    return OK

func export_hardware_json() -> String:
    return JSON.stringify({
        "hex": primary_color.to_html(false).to_upper(),
        "r": roundi(primary_color.r * 255.0),
        "g": roundi(primary_color.g * 255.0),
        "b": roundi(primary_color.b * 255.0),
        "effect": "pulse" if pulse_speed > 0.0 else "steady",
        "speed": pulse_speed,
        "brightness": glow_intensity
    }, "\t")
