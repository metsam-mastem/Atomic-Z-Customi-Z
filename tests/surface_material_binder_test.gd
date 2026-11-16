extends SceneTree

const BinderScript = preload("res://scripts/surface_material_binder.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var root_node := Node3D.new()
	root.add_child(root_node)
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "Body"
	var mesh := ArrayMesh.new()
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array([
		Vector3.ZERO, Vector3.RIGHT, Vector3.UP
	])
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var base_a := StandardMaterial3D.new()
	base_a.albedo_color = Color.RED
	var base_b := StandardMaterial3D.new()
	base_b.albedo_color = Color.BLUE
	mesh.surface_set_material(0, base_a)
	mesh.surface_set_material(1, base_b)
	mesh_instance.mesh = mesh
	root_node.add_child(mesh_instance)

	var binder = BinderScript.new()
	var definitions := [
		{"surface_id": "body.paint", "node_path": "Body", "surface_index": 0},
		{"surface_id": "body.trim", "node_path": "Body", "surface_index": 1}
	]
	var configured: Dictionary = binder.configure(root_node, definitions)
	if not configured.get("ok", false):
		push_error("Valid multi-surface bindings must configure: %s" % configured.get("errors", []))
		quit(1)
		return

	var requested := StandardMaterial3D.new()
	requested.albedo_color = Color.GREEN
	var applied: Material = binder.apply_material("body.paint", requested)
	if applied == null or applied == requested:
		push_error("Known surface must receive an isolated material duplicate.")
		quit(1)
		return
	if mesh_instance.get_surface_override_material(0) != applied:
		push_error("The selected surface must receive the instance material override.")
		quit(1)
		return
	if mesh_instance.get_surface_override_material(1) != null:
		push_error("Editing one surface must not override another surface.")
		quit(1)
		return
	if mesh.surface_get_material(0) != base_a or mesh.surface_get_material(1) != base_b:
		push_error("Imported base PBR materials must remain unchanged.")
		quit(1)
		return
	var applied_standard := applied as StandardMaterial3D
	applied_standard.albedo_color = Color.YELLOW
	if requested.albedo_color != Color.GREEN:
		push_error("Editing the per-build duplicate must not mutate the source material.")
		quit(1)
		return
	if not binder.clear_material_override("body.paint") or mesh_instance.get_surface_override_material(0) != null:
		push_error("Clearing an override must affect only the selected surface.")
		quit(1)
		return

	var duplicate_result: Dictionary = binder.configure(root_node, [
		{"surface_id": "duplicate", "node_path": "Body", "surface_index": 0},
		{"surface_id": "duplicate", "node_path": "Body", "surface_index": 1}
	])
	if duplicate_result.get("ok", true):
		push_error("Duplicate stable surface IDs must be rejected.")
		quit(1)
		return
	if not binder.has_surface("body.paint"):
		push_error("Rejected reconfiguration must preserve the last valid binding table.")
		quit(1)
		return

	var missing_result: Dictionary = binder.configure(root_node, [
		{"surface_id": "missing", "node_path": "NoSuchMesh", "surface_index": 0}
	])
	if missing_result.get("ok", true):
		push_error("Unknown mesh node paths must be rejected.")
		quit(1)
		return
	if not binder.has_surface("body.trim"):
		push_error("Failed configuration must not replace previously valid bindings.")
		quit(1)
		return

	var alias_result: Dictionary = binder.configure(root_node, [
		{"surface_id": "body.paint", "node_path": "Body", "surface_index": 0},
		{"surface_id": "body.paint.alias", "node_path": "Body", "surface_index": 0}
	])
	if alias_result.get("ok", true):
		push_error("Two stable IDs must not point to the same mesh surface.")
		quit(1)
		return

	mesh_instance.material_override = StandardMaterial3D.new()
	var global_override_result: Dictionary = binder.configure(root_node, definitions)
	if global_override_result.get("ok", true):
		push_error("Global material_override conflicts must be rejected.")
		quit(1)
		return
	mesh_instance.material_override = null
	if not binder.has_surface("body.paint"):
		push_error("Rejected global override conflict must preserve the last valid binding table.")
		quit(1)
		return

	var reapply: Material = binder.apply_material("body.paint", requested)
	if reapply == null:
		push_error("A valid registered surface must accept a second binder-owned override.")
		quit(1)
		return
	var external_override := StandardMaterial3D.new()
	external_override.albedo_color = Color.MAGENTA
	mesh_instance.set_surface_override_material(0, external_override)
	if binder.clear_material_override("body.paint"):
		push_error("Binder must not clear a surface override replaced by another owner.")
		quit(1)
		return
	if mesh_instance.get_surface_override_material(0) != external_override:
		push_error("External surface override must remain untouched.")
		quit(1)
		return
	mesh_instance.set_surface_override_material(0, null)

	mesh_instance.material_override = StandardMaterial3D.new()
	var apply_conflict := binder.apply_material("body.paint", requested)
	if apply_conflict != null or mesh_instance.get_surface_override_material(0) != null:
		push_error("Apply must fail closed if a global material_override appears after configuration.")
		quit(1)
		return
	mesh_instance.material_override = null

	print("PASS: stable surface binding, isolated overrides, base material preservation and atomic validation.")
	quit(0)
