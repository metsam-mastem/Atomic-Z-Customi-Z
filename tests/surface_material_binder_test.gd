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
	if applied == null:
		push_error("Known surface ID must accept a material.")
		quit(1)
		return
	if applied == requested:
		push_error("Per-build material edits must duplicate the supplied resource.")
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

	var duplicate_result: Dictionary = binder.configure(root_node, [
		{"surface_id": "duplicate", "node_path": "Body", "surface_index": 0},
		{"surface_id": "duplicate", "node_path": "Body", "surface_index": 1}
	])
	if duplicate_result.get("ok", true):
		push_error("Duplicate stable surface IDs must be rejected.")
		quit(1)
		return

	var missing_result: Dictionary = binder.configure(root_node, [
		{"surface_id": "missing", "node_path": "NoSuchMesh", "surface_index": 0}
	])
	if missing_result.get("ok", true):
		push_error("Unknown mesh node paths must be rejected.")
		quit(1)
		return

	print("PASS: stable surface binding, isolated overrides, base material preservation and invalid binding rejection.")
	quit(0)
