extends RefCounted
class_name BuildDocument

const SCHEMA_VERSION := 1

static func create_default(vehicle_id: String = "vehicle-unassigned", display_name: String = "Unassigned vehicle") -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"project_id": "atomic-z-project",
		"revision": 1,
		"vehicle": {
			"vehicle_id": vehicle_id,
			"display_name": display_name,
			"model_year": null,
			"market": null,
			"variant": null,
			"units": "si",
			"coordinate_system": "right_handed_y_up"
		},
		"asset": {
			"uri": null,
			"sha256": null,
			"license": null,
			"source": null,
			"validation_status": "not_run"
		},
		"assembly": {"parts": []},
		"customization": {
			"materials": [],
			"graphic_layers": [],
			"neon_layers": []
		},
		"render": {
			"quality_tier": "adaptive",
			"environment": "garage",
			"glow_enabled": true,
			"glow_intensity": 0.8
		},
		"hardware_profiles": [],
		"validation": {"evidence": [], "status": "not_run"},
		"extensions": []
	}

static func from_legacy_neon(legacy: Dictionary) -> Dictionary:
	var model_name := str(legacy.get("bike_model", "Unassigned vehicle")).strip_edges()
	var vehicle_id := _stable_id(model_name)
	var document := create_default(vehicle_id, model_name)
	var colors: Dictionary = legacy.get("colors", {})
	var layers: Array = []
	var seen: Dictionary = {}
	for segment_value in legacy.get("line_segments", []):
		if not (segment_value is Dictionary):
			continue
		var segment: Dictionary = segment_value
		var segment_id := str(segment.get("id", "")).strip_edges()
		if segment_id.is_empty() or seen.has(segment_id):
			continue
		seen[segment_id] = true
		layers.append({
			"layer_id": segment_id,
			"name": segment_id.replace("_", " ").capitalize(),
			"kind": "neon_path",
			"target_part_id": null,
			"target_surface_id": null,
			"color_token": str(segment.get("color", "primary")),
			"width": float(segment.get("width", 1.0)),
			"visible": bool(segment.get("visible", true)),
			"points_legacy_2d": segment.get("points", []).duplicate(true),
			"mapping_status": "unverified_legacy_2d"
		})
	document["customization"]["neon_layers"] = layers
	document["customization"]["palette"] = {
		"primary": str(colors.get("primary", "#00FFCC")),
		"secondary": str(colors.get("secondary", "#FF00FF"))
	}
	document["render"]["glow_intensity"] = clampf(float(colors.get("glow_intensity", 0.8)), 0.0, 1.0)
	document["migration"] = {
		"source_format": "neon_skin_config",
		"source_skin_name": str(legacy.get("skin_name", "Imported skin")),
		"mapping_note": "Legacy 2D points are preserved but are not claimed to be surface-aligned."
	}
	return document

static func validate(document: Dictionary) -> Dictionary:
	var errors: Array[String] = []
	if int(document.get("schema_version", -1)) != SCHEMA_VERSION:
		errors.append("Unsupported schema_version.")
	if str(document.get("project_id", "")).strip_edges().is_empty():
		errors.append("project_id is required.")
	var vehicle: Variant = document.get("vehicle", null)
	if not (vehicle is Dictionary):
		errors.append("vehicle must be an object.")
	elif str(vehicle.get("vehicle_id", "")).strip_edges().is_empty():
		errors.append("vehicle.vehicle_id is required.")
	var customization: Variant = document.get("customization", null)
	if not (customization is Dictionary):
		errors.append("customization must be an object.")
	else:
		var neon_layers: Variant = customization.get("neon_layers", null)
		if not (neon_layers is Array):
			errors.append("customization.neon_layers must be an array.")
		else:
			var seen: Dictionary = {}
			for layer_value in neon_layers:
				if not (layer_value is Dictionary):
					errors.append("Every neon layer must be an object.")
					continue
				var layer: Dictionary = layer_value
				var layer_id := str(layer.get("layer_id", "")).strip_edges()
				if layer_id.is_empty() or seen.has(layer_id):
					errors.append("Neon layer IDs must be non-empty and unique.")
				else:
					seen[layer_id] = true
				if not (layer.get("color_token", "") in ["primary", "secondary"]):
					errors.append("Neon layer color_token must reference the shared palette.")
		var palette: Variant = customization.get("palette", {})
		if not (palette is Dictionary):
			errors.append("customization.palette must be an object.")
		else:
			for key in ["primary", "secondary"]:
				if not _is_hex_color(str(palette.get(key, ""))):
					errors.append("Palette color %s must be #RRGGBB or #RRGGBBAA." % key)
	var render: Variant = document.get("render", null)
	if not (render is Dictionary):
		errors.append("render must be an object.")
	elif float(render.get("glow_intensity", -1.0)) < 0.0 or float(render.get("glow_intensity", 2.0)) > 1.0:
		errors.append("render.glow_intensity must be between 0 and 1.")
	return {"ok": errors.is_empty(), "errors": errors}

static func to_json(document: Dictionary) -> String:
	return JSON.stringify(document, "\t")

static func from_json(json_text: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(json_text)
	if not (parsed is Dictionary):
		return {}
	if not validate(parsed).get("ok", false):
		return {}
	return parsed

static func _stable_id(label: String) -> String:
	var normalized := label.to_lower().strip_edges()
	var regex := RegEx.new()
	regex.compile("[^a-z0-9]+")
	normalized = regex.sub(normalized, "-", true).trim_prefix("-").trim_suffix("-")
	return normalized if not normalized.is_empty() else "vehicle-unassigned"

static func _is_hex_color(value: String) -> bool:
	var regex := RegEx.new()
	regex.compile("^#[0-9A-Fa-f]{6}([0-9A-Fa-f]{2})?$")
	return regex.search(value) != null
