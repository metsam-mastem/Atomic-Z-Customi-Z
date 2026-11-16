extends SceneTree

const BuildDocumentScript = preload("res://scripts/build_document.gd")
const BikeAssemblyScript = preload("res://scripts/bike_assembly.gd")
const NeonSkinScript = preload("res://scripts/neon_skin.gd")
const QualityControllerScript = preload("res://scripts/quality_controller.gd")
const GarageTouchGesturesScript = preload("res://scripts/garage_touch_gestures.gd")

func _initialize() -> void:
	call_deferred("_run_smoke_test")

func _run_smoke_test() -> void:
	var packed_scene: PackedScene = load("res://scenes/main.tscn")
	if packed_scene == null:
		push_error("Main scene could not be loaded.")
		quit(1)
		return

	var scene := packed_scene.instantiate()
	root.add_child(scene)
	await process_frame

	var bike := scene.get_node_or_null("MotorcyclePlaceholder")
	if bike == null:
		push_error("Procedural motorcycle root is missing.")
		quit(1)
		return

	var neon := scene.get_node_or_null("NeonSkinOverlay")
	if neon == null:
		push_error("Godot neon skin overlay is not integrated into the garage.")
		quit(1)
		return
	if neon.call("get_segment_ids") != ["tail_underglow", "tank_accent", "lower_fairing"]:
		push_error("Garage neon overlay did not load the expected skin segments.")
		quit(1)
		return

	var tank := bike.get_node_or_null("fuel_tank") as Node3D
	if tank == null:
		push_error("Fuel tank part is missing.")
		quit(1)
		return

	var stock_position := tank.position
	bike.call("set_exploded", true)
	await process_frame
	if tank.position.is_equal_approx(stock_position):
		push_error("Exploded mode did not move the fuel tank.")
		quit(1)
		return

	bike.call("set_exploded", false)
	await process_frame
	if not tank.position.is_equal_approx(stock_position):
		push_error("Stock mode did not restore the fuel tank.")
		quit(1)
		return

	var tank_mesh := tank.get_node_or_null("VisualMesh") as MeshInstance3D
	if tank_mesh == null:
		push_error("Fuel tank mesh is missing.")
		quit(1)
		return
	var material := tank_mesh.material_override as StandardMaterial3D
	if material == null:
		push_error("Fuel tank material is missing.")
		quit(1)
		return

	var test_color := Color(0.1, 0.8, 0.3, 1.0)
	bike.call("set_body_color", test_color)
	if not material.albedo_color.is_equal_approx(test_color):
		push_error("Body color change did not reach the fuel tank material.")
		quit(1)
		return

	var front_color_before: Color = bike.call("get_part_color", "front_fairing")
	var isolated_paint := Color("#2A7BDA")
	if not bike.call("set_part_color", "fuel_tank", isolated_paint):
		push_error("A known part must accept an isolated paint edit.")
		quit(1)
		return
	var isolated_tank_color: Color = bike.call("get_part_color", "fuel_tank")
	if not isolated_tank_color.is_equal_approx(isolated_paint):
		push_error("Selected part must receive the requested paint color.")
		quit(1)
		return
	var isolated_front_color: Color = bike.call("get_part_color", "front_fairing")
	if not isolated_front_color.is_equal_approx(front_color_before):
		push_error("Painting one part must not recolor another part.")
		quit(1)
		return
	var available_parts: Array = bike.call("get_part_ids")
	if not ("front_rim" in available_parts) or not ("rear_rim" in available_parts):
		push_error("Front and rear rims must be independently selectable customization parts.")
		quit(1)
		return
	var front_tire_color_before: Color = bike.call("get_part_color", "front_wheel")
	var rim_paint := Color("#B58A32")
	if not bike.call("set_part_color", "front_rim", rim_paint):
		push_error("The front rim must accept an independent paint edit.")
		quit(1)
		return
	var front_rim_color: Color = bike.call("get_part_color", "front_rim")
	if not front_rim_color.is_equal_approx(rim_paint):
		push_error("Front rim color edit did not reach the rim material.")
		quit(1)
		return
	var front_tire_color_after: Color = bike.call("get_part_color", "front_wheel")
	if not front_tire_color_after.is_equal_approx(front_tire_color_before):
		push_error("Painting the rim must not recolor the tire.")
		quit(1)
		return

	var project_color := Color(0.2, 0.4, 0.9, 1.0)
	scene.call("_on_body_color_changed", project_color)
	scene.call("_on_neon_primary_changed", Color("#123456"))
	scene.call("_on_glow_changed", 0.55)
	scene.call("_on_neon_toggled", false)
	bike.call("set_exploded", true)
	var saved_exploded_tank_position: Vector3 = tank.position
	var summary_label := scene.find_child("BuildSummaryLabel", true, false) as Label
	if summary_label == null or not summary_label.text.contains("BUILD  /") or not summary_label.text.contains("FUEL TANK"):
		push_error("Garage HUD must display the active BuildDocument and selected part.")
		quit(1)
		return
	var document: Dictionary = scene.call("get_build_document_snapshot")
	if document.get("schema_version") != 1:
		push_error("Garage must expose the canonical BuildDocument.")
		quit(1)
		return
	if document.get("assembly", {}).get("parts", []).size() < 10:
		push_error("Assembly parts must be represented in the shared BuildDocument.")
		quit(1)
		return
	if document.get("customization", {}).get("materials", []).is_empty():
		push_error("Body paint edits must update the shared BuildDocument.")
		quit(1)
		return
	var fuel_paint_record_found := false
	for material_record in document.get("customization", {}).get("materials", []):
		if material_record is Dictionary and str(material_record.get("material_id", "")) == "paint:fuel_tank":
			fuel_paint_record_found = material_record.get("target_part_ids", []) == ["fuel_tank"]
	if not fuel_paint_record_found:
		push_error("BuildDocument must persist the selected part's stable paint target.")
		quit(1)
		return
	if document.get("customization", {}).get("palette", {}).get("primary") != "#123456":
		push_error("Neon palette edits must update the shared BuildDocument.")
		quit(1)
		return
	if not is_equal_approx(float(document.get("render", {}).get("glow_intensity", -1.0)), 0.55):
		push_error("Glow edits must update the shared BuildDocument.")
		quit(1)
		return
	if not scene.call("save_project"):
		push_error("Unified BuildDocument must save successfully.")
		quit(1)
		return
	if not summary_label.text.contains("REVISION  /  2"):
		push_error("HUD must reflect the persisted BuildDocument revision after save.")
		quit(1)
		return
	var saved := FileAccess.open("user://atomic_z_build.json", FileAccess.READ)
	if saved == null:
		push_error("Saved BuildDocument file is missing.")
		quit(1)
		return
	var restored: Dictionary = BuildDocumentScript.from_json(saved.get_as_text())
	saved.close()
	if restored.is_empty() or restored.get("customization", {}).get("palette", {}).get("primary") != "#123456":
		push_error("Saved BuildDocument must preserve shared customization state.")
		quit(1)
		return
	if bool(restored.get("render", {}).get("neon_enabled", true)):
		push_error("Saved neon visibility must be stored in the canonical BuildDocument.")
		quit(1)
		return
	if str(restored.get("assembly", {}).get("mode", "")) != "exploded":
		push_error("Saved assembly mode must be stored in the canonical BuildDocument.")
		quit(1)
		return

	var restored_bike := BikeAssemblyScript.new()
	restored_bike.configure_build_document(restored)
	root.add_child(restored_bike)
	await process_frame
	var restored_tank_color: Color = restored_bike.get_part_color("fuel_tank")
	var restored_front_color: Color = restored_bike.get_part_color("front_fairing")
	var restored_tank_position: Vector3 = restored_bike.get_node("fuel_tank").position
	var expected_project_color := Color.from_string("#" + project_color.to_html(false).to_upper(), Color.WHITE)
	var expected_test_color := Color.from_string("#" + test_color.to_html(false).to_upper(), Color.WHITE)
	if not restored_tank_color.is_equal_approx(expected_project_color):
		push_error("Saved selected-part paint must be restored into the 3D assembly.")
		quit(1)
		return
	if not restored_front_color.is_equal_approx(expected_test_color):
		push_error("Saved paint for another part must remain independent after reload.")
		quit(1)
		return
	var restored_rim_color: Color = restored_bike.get_part_color("front_rim")
	if not restored_rim_color.is_equal_approx(Color("#B58A32")):
		push_error("Saved alloy rim paint must be restored independently after reload.")
		quit(1)
		return
	if not restored_tank_position.is_equal_approx(saved_exploded_tank_position):
		push_error("Saved Stock/Exploded mode must restore the assembly transforms.")
		quit(1)
		return

	var restored_neon := NeonSkinScript.new()
	restored_neon.configure_build_document(restored)
	root.add_child(restored_neon)
	await process_frame
	for neon_visual in restored_neon.get_children():
		if neon_visual.visible:
			push_error("Saved disabled neon state must be restored into the runtime visuals.")
			quit(1)
			return

	for path in ["user://atomic_z_build.json", "user://atomic_z_build.json.tmp", "user://atomic_z_build.json.bak"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

	if not _test_quality_controller():
		quit(1)
		return

	if not _test_touch_gestures():
		quit(1)
		return

	print("PASS: part-isolated paint, canonical state, neon visibility, save/reload recovery and multi-touch camera gestures.")

	quit(0)


func _test_quality_controller() -> bool:
	var key_light := DirectionalLight3D.new()
	key_light.shadow_enabled = true
	var controller = QualityControllerScript.new()
	root.add_child(key_light)
	root.add_child(controller)
	controller.configure(key_light)

	controller.call("submit_fps_sample", 24.0)
	controller.call("submit_fps_sample", 0.0)
	if bool(controller.call("is_reduced_quality")):
		push_error("One low sample and an invalid zero-FPS sample must not reduce quality.")
		return false

	controller.call("submit_fps_sample", 24.0)
	if not bool(controller.call("is_reduced_quality")) or key_light.shadow_enabled:
		push_error("Two consecutive low-FPS samples must disable key-light shadows.")
		return false

	var replacement_light := DirectionalLight3D.new()
	replacement_light.shadow_enabled = true
	root.add_child(replacement_light)
	controller.configure(replacement_light)
	if replacement_light.shadow_enabled:
		push_error("A replacement key light must inherit the current reduced-quality state.")
		return false

	controller.call("submit_fps_sample", 36.0)
	for _sample in range(3):
		controller.call("submit_fps_sample", 55.0)
	if not bool(controller.call("is_reduced_quality")) or replacement_light.shadow_enabled:
		push_error("Quality must remain reduced until four consecutive high-FPS samples arrive.")
		return false

	controller.call("submit_fps_sample", 36.0)
	for _sample in range(3):
		controller.call("submit_fps_sample", 55.0)
	if not bool(controller.call("is_reduced_quality")):
		push_error("A neutral sample must reset the high-FPS recovery counter.")
		return false

	controller.call("submit_fps_sample", 55.0)
	if bool(controller.call("is_reduced_quality")) or not replacement_light.shadow_enabled:
		push_error("Four consecutive high-FPS samples must restore key-light shadows.")
		return false


	var frame_light := DirectionalLight3D.new()
	var frame_controller = QualityControllerScript.new()
	root.add_child(frame_light)
	root.add_child(frame_controller)
	frame_controller.configure(frame_light)
	var tier_changes: Array[String] = []
	frame_controller.quality_tier_changed.connect(func(tier: String, _fps: float) -> void:
		tier_changes.append(tier)
	)
	if not frame_controller.has_method("record_frame"):
		push_error("QualityController must expose frame-delta sampling for the runtime.")
		return false
	if frame_controller.call("get_quality_tier") != "quality":
		push_error("Adaptive quality must expose its initial quality tier.")
		return false

	# A suspended/resumed app must discard a partial sample window.
	for _frame in range(20):
		frame_controller.call("record_frame", 0.05)
	frame_controller.call("record_frame", 3.0)
	for _frame in range(20):
		frame_controller.call("record_frame", 0.05)
	if not is_equal_approx(float(frame_controller.call("get_last_measured_fps")), 0.0):
		push_error("A long app-resume pause must not be counted as an FPS sample.")
		return false
	# Complete one clean two-second post-resume window at 20 FPS.
	for _frame in range(20):
		frame_controller.call("record_frame", 0.05)
	if not is_equal_approx(float(frame_controller.call("get_last_measured_fps")), 20.0):
		push_error("Quality telemetry must expose FPS measured over the complete two-second window.")
		return false
	if not is_equal_approx(float(frame_controller.call("get_last_frame_time_ms")), 50.0):
		push_error("Quality telemetry must expose the corresponding frame-time estimate.")
		return false
	if bool(frame_controller.call("is_reduced_quality")):
		push_error("A single low-FPS window must not switch the quality tier.")
		return false
	_feed_quality_window(frame_controller, 20)
	if frame_controller.call("get_quality_tier") != "performance" or frame_light.shadow_enabled:
		push_error("Two consecutive low-FPS windows must switch to performance tier.")
		return false
	if tier_changes != ["performance"]:
		push_error("Quality-tier change signal must emit exactly once when entering performance tier.")
		return false
	for _window in range(3):
		_feed_quality_window(frame_controller, 60)
	if not bool(frame_controller.call("is_reduced_quality")):
		push_error("Three high-FPS windows must not restore the quality tier.")
		return false
	_feed_quality_window(frame_controller, 40)
	for _window in range(3):
		_feed_quality_window(frame_controller, 60)
	if not bool(frame_controller.call("is_reduced_quality")):
		push_error("A neutral window must reset the high-FPS recovery sequence.")
		return false
	_feed_quality_window(frame_controller, 60)
	if frame_controller.call("get_quality_tier") != "quality" or not frame_light.shadow_enabled:
		push_error("Four consecutive high-FPS windows must restore the quality tier.")
		return false
	if tier_changes != ["performance", "quality"]:
		push_error("Quality-tier change signal must emit once for each actual tier transition.")
		return false
	_feed_quality_window(frame_controller, 20)
	_feed_quality_window(frame_controller, 20)
	frame_controller.call("reset_adaptive_state")
	if frame_controller.call("get_quality_tier") != "quality" or not frame_light.shadow_enabled:
		push_error("Reset must restore the default quality tier and shadows.")
		return false
	if not is_equal_approx(float(frame_controller.call("get_last_measured_fps")), 0.0):
		push_error("Reset must clear stale FPS telemetry.")
		return false
	if tier_changes != ["performance", "quality", "performance", "quality"]:
		push_error("Reset must emit a single event when it changes the active tier.")
		return false

	frame_controller.free()
	frame_light.free()
	controller.free()
	key_light.free()
	replacement_light.free()
	return true


func _feed_quality_window(controller: Node, fps: int) -> void:
	var frame_count := fps * 2
	var frame_delta := 2.0 / float(frame_count)
	for _frame in range(frame_count):
		controller.call("record_frame", frame_delta)


func _test_touch_gestures() -> bool:
	var sync_probe = GarageTouchGesturesScript.new()
	sync_probe.sync_camera_state(0.75, 0.2, 6.2, Vector3(0.5, 0.25, -0.4))
	var synchronized: Dictionary = sync_probe.get_camera_state()
	if not is_equal_approx(float(synchronized.get("orbit_angle", 0.0)), 0.75):
		push_error("Touch gestures must inherit the current camera orbit after mouse interaction.")
		return false
	if not is_equal_approx(float(synchronized.get("orbit_distance", 0.0)), 6.2):
		push_error("Touch gestures must inherit the current camera zoom after mouse interaction.")
		return false
	var synchronized_offset: Vector3 = synchronized.get("target_offset", Vector3.ZERO)
	if not synchronized_offset.is_equal_approx(Vector3(0.5, 0.25, -0.4)):
		push_error("Touch gestures must inherit the current camera pan offset.")
		return false

	var gestures = GarageTouchGesturesScript.new()
	var initial: Dictionary = gestures.get_camera_state()
	var first_down := InputEventScreenTouch.new()
	first_down.index = 0
	first_down.pressed = true
	first_down.position = Vector2(100.0, 100.0)
	gestures.handle_event(first_down)

	var one_finger_drag := InputEventScreenDrag.new()
	one_finger_drag.index = 0
	one_finger_drag.position = Vector2(150.0, 115.0)
	gestures.handle_event(one_finger_drag)
	var orbited: Dictionary = gestures.get_camera_state()
	if is_equal_approx(float(orbited.get("orbit_angle", 0.0)), float(initial.get("orbit_angle", 0.0))):
		push_error("Single-finger touch must orbit the garage camera.")
		return false

	var second_down := InputEventScreenTouch.new()
	second_down.index = 1
	second_down.pressed = true
	second_down.position = Vector2(250.0, 115.0)
	gestures.handle_event(second_down)
	var before_pinch: float = float(gestures.get_camera_state().get("orbit_distance", 0.0))
	var two_finger_drag := InputEventScreenDrag.new()
	two_finger_drag.index = 1
	two_finger_drag.position = Vector2(310.0, 115.0)
	gestures.handle_event(two_finger_drag)
	var pinched: Dictionary = gestures.get_camera_state()
	if not float(pinched.get("orbit_distance", 0.0)) < before_pinch:
		push_error("Two-finger pinch-out must zoom the garage camera in.")
		return false
	var pan_offset: Vector3 = pinched.get("target_offset", Vector3.ZERO)
	if pan_offset.is_equal_approx(Vector3.ZERO):
		push_error("Two-finger centroid movement must pan the garage camera target.")
		return false

	var distance_after_zoom_in: float = float(pinched.get("orbit_distance", 0.0))
	var pinch_in := InputEventScreenDrag.new()
	pinch_in.index = 1
	pinch_in.position = Vector2(175.0, 115.0)
	gestures.handle_event(pinch_in)
	var zoomed_out: Dictionary = gestures.get_camera_state()
	if not float(zoomed_out.get("orbit_distance", 0.0)) > distance_after_zoom_in:
		push_error("Two-finger pinch-in must zoom the garage camera out.")
		return false

	var clamp_drag := InputEventScreenDrag.new()
	clamp_drag.index = 1
	clamp_drag.position = Vector2(5000.0, 115.0)
	gestures.handle_event(clamp_drag)
	var clamped: Dictionary = gestures.get_camera_state()
	if not is_equal_approx(float(clamped.get("orbit_distance", 0.0)), 3.0):
		push_error("Pinch zoom must respect the minimum camera distance.")
		return false
	var max_clamp_drag := InputEventScreenDrag.new()
	max_clamp_drag.index = 1
	max_clamp_drag.position = Vector2(150.0, 115.0)
	gestures.handle_event(max_clamp_drag)
	var max_clamped: Dictionary = gestures.get_camera_state()
	if not is_equal_approx(float(max_clamped.get("orbit_distance", 0.0)), 8.0):
		push_error("Pinch zoom must respect the maximum camera distance.")
		return false

	var second_up := InputEventScreenTouch.new()
	second_up.index = 1
	second_up.pressed = false
	second_up.position = Vector2(310.0, 115.0)
	gestures.handle_event(second_up)
	gestures.reset()
	var reset_state: Dictionary = gestures.get_camera_state()
	if not is_equal_approx(float(reset_state.get("orbit_distance", 0.0)), 5.3):
		push_error("Reset must restore the default garage camera distance.")
		return false
	var reset_offset: Vector3 = reset_state.get("target_offset", Vector3.ONE)
	if not reset_offset.is_equal_approx(Vector3.ZERO):
		push_error("Reset must clear the camera pan offset.")
		return false

	var cancellation_probe = GarageTouchGesturesScript.new()
	var cancel_first := InputEventScreenTouch.new()
	cancel_first.index = 0
	cancel_first.pressed = true
	cancel_first.position = Vector2(100.0, 100.0)
	cancellation_probe.handle_event(cancel_first)
	var cancel_second := InputEventScreenTouch.new()
	cancel_second.index = 1
	cancel_second.pressed = true
	cancel_second.position = Vector2(200.0, 100.0)
	cancellation_probe.handle_event(cancel_second)
	var cancelled := InputEventScreenTouch.new()
	cancelled.index = 1
	cancelled.pressed = false
	cancelled.canceled = true
	cancelled.position = Vector2(200.0, 100.0)
	cancellation_probe.handle_event(cancelled)
	var remaining_drag := InputEventScreenDrag.new()
	remaining_drag.index = 0
	remaining_drag.position = Vector2(125.0, 100.0)
	cancellation_probe.handle_event(remaining_drag)
	var after_cancel: Dictionary = cancellation_probe.get_camera_state()
	if is_equal_approx(float(after_cancel.get("orbit_angle", 0.0)), 0.0):
		push_error("A surviving finger must resume one-finger orbit after another touch is cancelled.")
		return false
	var after_cancel_offset: Vector3 = after_cancel.get("target_offset", Vector3.ZERO)
	if not after_cancel_offset.is_equal_approx(Vector3.ZERO):
		push_error("Cancelled touches must not leave a stale multi-touch pan gesture active.")
		return false
	return true
