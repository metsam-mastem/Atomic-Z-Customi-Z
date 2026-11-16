extends RefCounted
class_name SurfaceMaterialBinder

var _root: Node
var _bindings: Dictionary = {}

## Configure stable surface IDs against an imported scene.
## Each entry: {surface_id: String, node_path: NodePath/String, surface_index: int}.
## Configuration is atomic: invalid input never replaces the last valid binding set.
func configure(scene_root: Node, definitions: Array) -> Dictionary:
	if scene_root == null:
		return {"ok": false, "errors": ["A scene root is required."]}

	var candidate: Dictionary = {}
	var occupied_slots: Dictionary = {}
	var errors: Array[String] = []
	for definition_value in definitions:
		if not (definition_value is Dictionary):
			errors.append("Every surface binding must be a Dictionary.")
			continue

		var definition: Dictionary = definition_value
		var surface_id := str(definition.get("surface_id", "")).strip_edges()
		if surface_id.is_empty():
			errors.append("surface_id must be a non-empty stable identifier.")
			continue
		if candidate.has(surface_id):
			errors.append("Duplicate surface_id: %s" % surface_id)
			continue

		if not definition.has("node_path") or not definition.has("surface_index"):
			errors.append("Binding %s requires node_path and surface_index." % surface_id)
			continue

		var node_path := NodePath(str(definition["node_path"]))
		var target := scene_root.get_node_or_null(node_path)
		if not (target is MeshInstance3D):
			errors.append("Binding %s does not resolve to a MeshInstance3D." % surface_id)
			continue

		var mesh_instance: MeshInstance3D = target
		if mesh_instance.material_override != null:
			errors.append("Binding %s conflicts with a global material_override; resolve it before surface binding." % surface_id)
			continue
		if mesh_instance.mesh == null:
			errors.append("Binding %s targets a mesh instance without a Mesh." % surface_id)
			continue
		if not (definition["surface_index"] is int):
			errors.append("Binding %s surface_index must be an integer." % surface_id)
			continue

		var surface_index := int(definition["surface_index"])
		if surface_index < 0 or surface_index >= mesh_instance.mesh.get_surface_count():
			errors.append("Binding %s surface_index is outside the mesh surface range." % surface_id)
			continue

		var slot_key := str(node_path) + "#" + str(surface_index)
		if occupied_slots.has(slot_key):
			errors.append("Multiple surface IDs target the same mesh surface: %s" % slot_key)
			continue
		occupied_slots[slot_key] = surface_id
		candidate[surface_id] = {
			"node_path": node_path,
			"surface_index": surface_index
		}

	if not errors.is_empty():
		return {"ok": false, "errors": errors}

	_root = scene_root
	_bindings = candidate
	return {"ok": true, "errors": [], "surface_ids": _bindings.keys()}

## Applies a duplicated material to exactly one registered surface.
## Returns the per-instance duplicate, or null when the ID/material is invalid.
func apply_material(surface_id: String, source_material: Material) -> Material:
	if source_material == null or not _bindings.has(surface_id):
		return null
	var mesh_instance := _resolve_mesh_instance(surface_id)
	if mesh_instance == null:
		return null

	var surface_index := int(_bindings[surface_id]["surface_index"])
	if mesh_instance.mesh == null or surface_index >= mesh_instance.mesh.get_surface_count():
		return null

	var instance_material := source_material.duplicate(true) as Material
	if instance_material == null:
		return null
	mesh_instance.set_surface_override_material(surface_index, instance_material)
	return instance_material

## Clears only the override registered to this stable surface ID.
func clear_material_override(surface_id: String) -> bool:
	if not _bindings.has(surface_id):
		return false
	var mesh_instance := _resolve_mesh_instance(surface_id)
	if mesh_instance == null:
		return false
	var surface_index := int(_bindings[surface_id]["surface_index"])
	if mesh_instance.mesh == null or surface_index >= mesh_instance.mesh.get_surface_count():
		return false
	mesh_instance.set_surface_override_material(surface_index, null)
	return true

func has_surface(surface_id: String) -> bool:
	return _bindings.has(surface_id) and _resolve_mesh_instance(surface_id) != null

func get_surface_ids() -> Array:
	return _bindings.keys()

func _resolve_mesh_instance(surface_id: String) -> MeshInstance3D:
	if _root == null or not _bindings.has(surface_id):
		return null
	var target := _root.get_node_or_null(_bindings[surface_id]["node_path"])
	if target is MeshInstance3D:
		return target
	return null
