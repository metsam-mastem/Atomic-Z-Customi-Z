extends SceneTree

const NeonSkinScript = preload("res://scripts/neon_skin.gd")
const BuildDocumentScript = preload("res://scripts/build_document.gd")

var _failed := false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var skin = NeonSkinScript.new()
	root.add_child(skin)
	var loaded: bool = skin.load_skin("res://neon_skin_config.json")
	_assert(loaded, "Valid legacy neon skin JSON must load.")
	if not loaded:
		quit(1)
		return

	_assert(skin.get_segment_ids() == ["tail_underglow", "tank_accent", "lower_fairing"], "Neon segment IDs must remain stable and ordered.")
	_assert(is_equal_approx(skin.get_glow_intensity(), 0.8), "Glow intensity must be read from the legacy import.")
	_assert(skin.get_segment_color("tank_accent") == Color("#FF00FF"), "Named secondary color must resolve correctly.")
	_assert(skin.set_segment_visible("tank_accent", false), "Existing segment visibility must be controllable.")
	_assert(skin.set_palette_color("primary", Color("#112233")), "Known palette entries must be editable.")
	_assert(skin.get_segment_color("tail_underglow") == Color("#112233"), "Palette edits must propagate to linked segments.")

	skin.set_glow_intensity(2.0)
	_assert(is_equal_approx(skin.get_glow_intensity(), 1.0), "Glow intensity must clamp to the normalized range.")
	_assert(not skin.set_segment_visible("missing_segment", false), "Unknown segment IDs must be rejected.")
	_assert(not skin.load_skin("res://tests/fixtures/invalid_neon_skin.json"), "Invalid color references must be rejected.")
	_assert(not skin.load_skin("res://tests/fixtures/invalid_glow_skin.json"), "Out-of-range glow values must be rejected.")
	_assert(skin.get_segment_ids() == ["tail_underglow", "tank_accent", "lower_fairing"], "Rejected config must not replace the last valid skin.")

	skin.set_skin_visible(false)
	var snapshot: Dictionary = skin.get_build_document_snapshot()
	_assert(BuildDocumentScript.validate(snapshot).get("ok", false), "Neon runtime state must remain part of a valid canonical BuildDocument.")
	_assert(snapshot.get("customization", {}).get("palette", {}).get("primary") == "#112233", "Primary palette changes must update the canonical BuildDocument.")
	_assert(is_equal_approx(float(snapshot.get("render", {}).get("glow_intensity", -1.0)), 1.0), "Normalized glow changes must update the canonical BuildDocument.")
	_assert(not bool(snapshot.get("render", {}).get("neon_enabled", true)), "Global neon visibility must update the canonical BuildDocument.")
	_assert(not skin.has_method("save_skin"), "NeonSkin must not expose an independent legacy JSON writer.")

	var layers: Array = snapshot.get("customization", {}).get("neon_layers", [])
	var hidden_segment_found := false
	for layer in layers:
		if layer is Dictionary and str(layer.get("layer_id", "")) == "tank_accent":
			hidden_segment_found = not bool(layer.get("visible", true))
	_assert(hidden_segment_found, "Per-segment visibility must be stored in the canonical BuildDocument.")

	var restored_document := BuildDocumentScript.from_json(BuildDocumentScript.to_json(snapshot))
	_assert(not restored_document.is_empty(), "Canonical neon state must survive BuildDocument JSON round-trip.")
	var restored = NeonSkinScript.new()
	restored.configure_build_document(restored_document)
	root.add_child(restored)
	await process_frame

	_assert(restored.get_segment_color("tail_underglow") == Color("#112233"), "BuildDocument round-trip must restore palette state.")
	_assert(is_equal_approx(restored.get_glow_intensity(), 1.0), "BuildDocument round-trip must restore normalized glow.")
	_assert(not restored.is_segment_visible("tank_accent"), "BuildDocument round-trip must restore per-segment visibility.")
	_assert(not bool(restored.get_build_document_snapshot().get("render", {}).get("neon_enabled", true)), "BuildDocument round-trip must restore global neon visibility.")

	if not _failed:
		print("PASS: legacy neon import, BuildDocument-backed edits, normalized glow and canonical round-trip.")
	quit(1 if _failed else 0)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		_failed = true
		push_error(message)
