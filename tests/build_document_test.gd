extends SceneTree

const BuildDocumentScript = preload("res://scripts/build_document.gd")

func _initialize() -> void:
	var legacy := {
		"bike_model": "Kawasaki Ninja ZX-25R",
		"skin_name": "Neon Cyberpunk",
		"colors": {
			"primary": "#00FFCC",
			"secondary": "#FF00FF",
			"glow_intensity": 0.8
		},
		"line_segments": [
			{"id": "tail_underglow", "color": "primary", "width": 2.0, "visible": true, "points": [[100, 300], [200, 320]]}
		]
	}
	var document: Dictionary = BuildDocumentScript.from_legacy_neon(legacy)
	_assert(document.get("schema_version") == 1, "Migration must stamp schema version 1.")
	_assert(document.get("vehicle", {}).get("vehicle_id") == "kawasaki-ninja-zx-25r", "Migration must create a stable vehicle ID.")
	_assert(document.get("customization", {}).get("neon_layers", []).size() == 1, "Migration must preserve neon segments.")
	_assert(BuildDocumentScript.validate(document).get("ok", false), "Migrated document must validate.")

	var encoded: String = BuildDocumentScript.to_json(document)
	var decoded: Dictionary = BuildDocumentScript.from_json(encoded)
	_assert(decoded == document, "BuildDocument JSON round-trip must preserve all data.")

	var invalid := document.duplicate(true)
	invalid["schema_version"] = 999
	_assert(not BuildDocumentScript.validate(invalid).get("ok", true), "Unknown schema versions must be rejected.")

	quit(0)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		quit(1)
