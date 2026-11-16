extends RefCounted
class_name SurfaceMaterialBinder

const BuildDocumentScript = preload("res://scripts/build_document.gd")

var _root: Node
var _bindings: Dictionary = {}
var _owned_overrides: Dictionary = {}

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

		var node_path_text := str(definition["node_path"])
		if node_path_text.is_empty() or node_path_text.begins_with("/") or node_path_text.contains(":"):
			errors.append("Binding %s requires a safe root-relative node_path." % surface_id)
			continue
		var unsafe_parent_path := false
		for path_segment in node_path_text.split("/", false):
			if path_segment == "..":
				unsafe_parent_path = true
		if unsafe_parent_path:
			errors.append("Binding %s cannot traverse outside the imported scene root." % surface_id)
			continue
		var node_path := NodePath(node_path_text)
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
		var surface_index_value: Variant = definition["surface_index"]
		var surface_index_is_integer := surface_index_value is int
		if surface_index_value is float:
			surface_index_is_integer = is_equal_approx(float(surface_index_value), floorf(float(surface_index_value)))
		if not surface_index_is_integer:
			errors.append("Binding %s surface_index must be an integer." % surface_id)
			continue

		var surface_index := int(surface_index_value)
		if surface_index < 0 or surface_index >= mesh_instance.mesh.get_surface_count():
			errors.append("Binding %s surface_index is outside the mesh surface range." % surface_id)
			continue

		var slot_key := str(mesh_instance.get_instance_id()) + "#" + str(surface_index)
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

## Configures bindings from the canonical BuildDocument asset catalog.
func configure_from_build_document(scene_root: Node, document: Dictionary) -> Dictionary:
	var document_validation: Dictionary = BuildDocumentScript.validate(document)
	if not document_validation.get("ok", false):
		return {"ok": false, "errors": document_validation.get("errors", ["BuildDocument is invalid."])}
	var asset_value: Variant = document.get("asset", null)
	if not (asset_value is Dictionary):
		return {"ok": false, "errors": ["BuildDocument asset must be an object."]}
	var catalog: Variant = asset_value.get("surface_catalog", [])
	if not (catalog is Array):
		return {"ok": false, "errors": ["BuildDocument asset.surface_catalog must be an array."]}
	return configure(scene_root, catalog)

## Applies a color edit and persists it to the same canonical BuildDocument.
## Only StandardMaterial3D surfaces are currently supported; other shader/material
## types fail closed rather than discarding their imported PBR/shader properties.
func set_surface_color(document: Dictionary, surface_id: String, color: Color) -> bool:
	if not _bindings.has(surface_id) or _resolve_mesh_instance(surface_id) == null:
		return false
	var candidate := document.duplicate(true)
	var customization_value: Variant = candidate.get("customization", null)
	if not (customization_value is Dictionary):
		return false
	var customization: Dictionary = customization_value
	var materials_value: Variant = customization.get("materials", [])
	if not (materials_value is Array):
		return false
	var materials: Array = materials_value.duplicate(true)
	var material_id := "surface-paint:" + surface_id
	var color_hex := "#" + color.to_html(false).to_upper()
	var record := {
		"material_id": material_id,
		"target_surface_ids": [surface_id],
		"base_color": color_hex
	}
	var found := false
	for index in range(materials.size()):
		if materials[index] is Dictionary and str(materials[index].get("material_id", "")) == material_id:
			materials[index] = record
			found = true
			break
	if not found:
		materials.append(record)
	customization["materials"] = materials
	candidate["customization"] = customization
	if not BuildDocumentScript.validate(candidate).get("ok", false):
		return false
	if apply_surface_color(surface_id, color) == null:
		return false
	document.clear()
	document.merge(candidate, true)
	return true

## Duplicates the imported/owned StandardMaterial3D and changes only its albedo.
func apply_surface_color(surface_id: String, color: Color) -> StandardMaterial3D:
	if not _bindings.has(surface_id):
		return null
	var mesh_instance := _resolve_mesh_instance(surface_id)
	if mesh_instance == null or mesh_instance.mesh == null or mesh_instance.material_override != null:
		return null
	var surface_index := int(_bindings[surface_id]["surface_index"])
	if surface_index < 0 or surface_index >= mesh_instance.mesh.get_surface_count():
		return null
	var current_override := mesh_instance.get_surface_override_material(surface_index)
	var source_material: Material = null
	if current_override != null:
		if not _owned_overrides.has(surface_id):
			return null
		var ownership: Dictionary = _owned_overrides[surface_id]
		if int(ownership.get("instance_id", -1)) != mesh_instance.get_instance_id():
			return null
		if int(ownership.get("surface_index", -1)) != surface_index:
			return null
		if ownership.get("material") != current_override:
			return null
		source_material = current_override
	else:
		source_material = mesh_instance.mesh.surface_get_material(surface_index)
	if not (source_material is StandardMaterial3D):
		return null
	var edited_material := source_material.duplicate(true) as StandardMaterial3D
	if edited_material == null:
		return null
	edited_material.albedo_color = color
	mesh_instance.set_surface_override_material(surface_index, edited_material)
	_owned_overrides[surface_id] = {
		"instance_id": mesh_instance.get_instance_id(),
		"surface_index": surface_index,
		"material": edited_material
	}
	return edited_material

## Applies a duplicated material to exactly one registered surface.
## Returns the per-instance duplicate, or null when the ID/material is invalid.
func apply_material(surface_id: String, source_material: Material) -> Material:
	if source_material == null or not _bindings.has(surface_id):
		return null
	var mesh_instance := _resolve_mesh_instance(surface_id)
	if mesh_instance == null or mesh_instance.material_override != null:
		return null

	var surface_index := int(_bindings[surface_id]["surface_index"])
	if mesh_instance.mesh == null or surface_index >= mesh_instance.mesh.get_surface_count():
		return null

	var current_override := mesh_instance.get_surface_override_material(surface_index)
	if current_override != null:
		if not _owned_overrides.has(surface_id):
			return null
		var previous_ownership: Dictionary = _owned_overrides[surface_id]
		if int(previous_ownership.get("instance_id", -1)) != mesh_instance.get_instance_id():
			return null
		if int(previous_ownership.get("surface_index", -1)) != surface_index:
			return null
		if previous_ownership.get("material") != current_override:
			return null

	var instance_material := source_material.duplicate(true) as Material
	if instance_material == null:
		return null
	mesh_instance.set_surface_override_material(surface_index, instance_material)
	_owned_overrides[surface_id] = {
		"instance_id": mesh_instance.get_instance_id(),
		"surface_index": surface_index,
		"material": instance_material
	}
	return instance_material

## Clears only the override registered to this stable surface ID.
func clear_material_override(surface_id: String) -> bool:
	if not _bindings.has(surface_id):
		return false
	var mesh_instance := _resolve_mesh_instance(surface_id)
	if mesh_instance == null:
		return false
	if not _owned_overrides.has(surface_id):
		return false
	var ownership: Dictionary = _owned_overrides[surface_id]
	var surface_index := int(_bindings[surface_id]["surface_index"])
	if mesh_instance.mesh == null or surface_index >= mesh_instance.mesh.get_surface_count():
		_owned_overrides.erase(surface_id)
		return false
	if int(ownership.get("instance_id", -1)) != mesh_instance.get_instance_id():
		_owned_overrides.erase(surface_id)
		return false
	if int(ownership.get("surface_index", -1)) != surface_index:
		_owned_overrides.erase(surface_id)
		return false
	if mesh_instance.get_surface_override_material(surface_index) != ownership.get("material"):
		_owned_overrides.erase(surface_id)
		return false
	mesh_instance.set_surface_override_material(surface_index, null)
	_owned_overrides.erase(surface_id)
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
