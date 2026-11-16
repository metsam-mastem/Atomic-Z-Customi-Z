extends SceneTree

const NeonSkinScript = preload("res://scripts/neon_skin.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var skin = NeonSkinScript.new()
	root.add_child(skin)
	var loaded: bool = skin.load_skin("res://neon_skin_config.json")
	if not loaded:
		push_error("Valid neon skin JSON must load.")
		quit(1)
		return
	if skin.get_segment_ids() != ["tail_underglow", "tank_accent", "lower_fairing"]:
		push_error("Neon segment IDs must remain stable and ordered.")
		quit(1)
		return
	if not is_equal_approx(skin.get_glow_intensity(), 0.8):
		push_error("Glow intensity must be read from JSON.")
		quit(1)
		return
	if skin.get_segment_color("tank_accent") != Color("#FF00FF"):
		push_error("Named secondary color must resolve correctly.")
		quit(1)
		return
	if not skin.set_segment_visible("tank_accent", false):
		push_error("Existing segment visibility must be controllable.")
		quit(1)
		return
	if not skin.set_palette_color("primary", Color("#112233")):
		push_error("Known palette entries must be editable.")
		quit(1)
		return
	if skin.get_segment_color("tail_underglow") != Color("#112233"):
		push_error("Palette edits must propagate to linked segments.")
		quit(1)
		return
	skin.set_glow_intensity(2.0)
	if not is_equal_approx(skin.get_glow_intensity(), 1.0):
		push_error("Glow intensity must clamp to the normalized range.")
		quit(1)
		return
	if skin.set_segment_visible("missing_segment", false):
		push_error("Unknown segment IDs must be rejected.")
		quit(1)
		return
	if skin.load_skin("res://tests/fixtures/invalid_neon_skin.json"):
		push_error("Invalid color references must be rejected.")
		quit(1)
		return
	if skin.load_skin("res://tests/fixtures/invalid_glow_skin.json"):
		push_error("Out-of-range glow values must be rejected.")
		quit(1)
		return
	if skin.get_segment_ids() != ["tail_underglow", "tank_accent", "lower_fairing"]:
		push_error("Rejected config must not replace the last valid skin.")
		quit(1)
		return
	print("PASS: neon skin JSON loading, stable IDs, palette editing, glow clamping and visibility.")
	quit(0)
