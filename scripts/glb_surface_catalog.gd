extends RefCounted
class_name GlbSurfaceCatalog

const BuildDocumentScript = preload("res://scripts/build_document.gd")

## Enumerates every MeshInstance3D surface in an imported GLB scene.
## The returned inventory is diagnostic; stable IDs are supplied by the canonical manifest.
static func inspect_scene(scene_root: Node) -> Dictionary:
	if scene_root == null:
		return {"ok": false, "errors": ["A scene root is required."], "surfaces": []}
	var surfaces: Array[Dictionary] = []
	_collect_surfaces(scene_root, scene_root, surfaces)
	return {"ok": true, "errors": [], "surfaces": surfaces}

## Validates stable manifest IDs against the actual imported scene without mutating it.
static func validate_manifest(scene_root: Node, definitions: Array) -> Dictionary:
	if scene_root == null:
		return {"ok": false, "errors": ["A scene root is required."], "surface_catalog": []}
	var candidate: Array[Dictionary] = []
	var seen_ids: Dictionary = {}
	var occupied_slots: Dictionary = {}
	var errors: Array[String] = []

	for definition_value in definitions:
		if not (definition_value is Dictionary):
			errors.append("Every surface definition must be a Dictionary.")
			continue
		var definition: Dictionary = definition_value
		var surface_id := str(definition.get("surface_id", "")).strip_edges()
		var node_path_text := str(definition.get("node_path", "")).strip_edges()
		var surface_index_value: Variant = definition.get("surface_index", null)
		if surface_id.is_empty():
			errors.append("surface_id must be a non-empty stable identifier.")
			continue
		if seen_ids.has(surface_id):
			errors.append("Duplicate surface_id: %s" % surface_id)
			continue
		seen_ids[surface_id] = true
		if node_path_text.is_empty():
			errors.append("Surface %s requires a root-relative node_path." % surface_id)
			continue
		var surface_index_is_integer := surface_index_value is int
		if surface_index_value is float:
			surface_index_is_integer = is_equal_approx(float(surface_index_value), floorf(float(surface_index_value)))
		if not surface_index_is_integer or float(surface_index_value) < 0.0:
			errors.append("Surface %s requires a non-negative integer surface_index." % surface_id)
			continue

		var target := scene_root.get_node_or_null(NodePath(node_path_text))
		if not (target is MeshInstance3D):
			errors.append("Surface %s does not resolve to a MeshInstance3D." % surface_id)
			continue
		var mesh_instance: MeshInstance3D = target
		if mesh_instance.mesh == null:
			errors.append("Surface %s targets a MeshInstance3D without a Mesh." % surface_id)
			continue
		if mesh_instance.material_override != null:
			errors.append("Surface %s conflicts with a global material_override." % surface_id)
			continue
		var surface_index := int(surface_index_value)
		if surface_index >= mesh_instance.mesh.get_surface_count():
			errors.append("Surface %s index is outside the mesh surface range." % surface_id)
			continue

		var slot_key := node_path_text + "#" + str(surface_index)
		if occupied_slots.has(slot_key):
			errors.append("Multiple surface IDs target the same mesh surface: %s" % slot_key)
			continue
		occupied_slots[slot_key] = surface_id

		var part_id := str(definition.get("part_id", "")).strip_edges()
		var record := {
			"surface_id": surface_id,
			"node_path": node_path_text,
			"surface_index": surface_index,
			"source_material_name": _source_material_name(mesh_instance.mesh.surface_get_material(surface_index))
		}
		if not part_id.is_empty():
			record["part_id"] = part_id
		candidate.append(record)

	if not errors.is_empty():
		return {"ok": false, "errors": errors, "surface_catalog": []}
	return {"ok": true, "errors": [], "surface_catalog": candidate}

## Returns a new BuildDocument with the validated catalog; the input remains untouched on failure.
static func attach_to_document(document: Dictionary, scene_root: Node, definitions: Array) -> Dictionary:
	var manifest_result := validate_manifest(scene_root, definitions)
	if not manifest_result.get("ok", false):
		return manifest_result
	var candidate := document.duplicate(true)
	var asset_value: Variant = candidate.get("asset", null)
	if not (asset_value is Dictionary):
		return {"ok": false, "errors": ["BuildDocument asset must be an object."], "surface_catalog": []}
	var asset: Dictionary = asset_value
	asset["surface_catalog"] = manifest_result["surface_catalog"].duplicate(true)
	candidate["asset"] = asset
	var validation: Dictionary = BuildDocumentScript.validate(candidate)
	if not validation.get("ok", false):
		return {"ok": false, "errors": validation.get("errors", []), "surface_catalog": []}
	return {
		"ok": true,
		"errors": [],
		"document": candidate,
		"surface_catalog": manifest_result["surface_catalog"]
	}

static func _collect_surfaces(current: Node, scene_root: Node, output: Array[Dictionary]) -> void:
	if current is MeshInstance3D:
		var mesh_instance: MeshInstance3D = current
		if mesh_instance.mesh != null:
			var node_path := "." if current == scene_root else str(scene_root.get_path_to(current))
			for surface_index in range(mesh_instance.mesh.get_surface_count()):
				var source_material: Material = mesh_instance.mesh.surface_get_material(surface_index)
				output.append({
					"node_path": node_path,
					"surface_index": surface_index,
					"surface_name": mesh_instance.mesh.surface_get_name(surface_index),
					"source_material_name": _source_material_name(source_material),
					"has_global_material_override": mesh_instance.material_override != null,
					"has_surface_override": mesh_instance.get_surface_override_material(surface_index) != null
				})
	for child in current.get_children():
		_collect_surfaces(child, scene_root, output)

static func _source_material_name(material: Material) -> String:
	if material == null:
		return ""
	return material.resource_name
