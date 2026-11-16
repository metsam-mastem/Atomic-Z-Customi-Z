extends RefCounted
class_name GlbVehicleRuntime

const BuildDocumentScript = preload("res://scripts/build_document.gd")
const GlbSurfaceCatalogScript = preload("res://scripts/glb_surface_catalog.gd")
const SurfaceMaterialBinderScript = preload("res://scripts/surface_material_binder.gd")

## Loads a local GLB only when its provenance, pinned SHA-256 and surface catalog
## are present in the canonical BuildDocument. No network access is performed.
static func instantiate_from_document(document: Dictionary) -> Dictionary:
	var validation: Dictionary = BuildDocumentScript.validate(document)
	if not validation.get("ok", false):
		return _failure("BuildDocument validation failed: " + str(validation.get("errors", [])))

	var asset_value: Variant = document.get("asset", null)
	if not (asset_value is Dictionary):
		return _failure("BuildDocument asset metadata is missing.")
	var asset: Dictionary = asset_value
	var asset_uri := str(asset.get("uri", "")).strip_edges()
	if not _is_safe_local_glb_uri(asset_uri):
		return _failure("Asset URI must be a safe local res:// or user:// .glb path.")
	if not FileAccess.file_exists(asset_uri):
		return _failure("GLB file does not exist: " + asset_uri)

	var expected_hash := str(asset.get("sha256", "")).to_lower()
	if not _is_sha256(expected_hash):
		return _failure("A 64-character SHA-256 is required before importing a GLB.")
	if FileAccess.get_sha256(asset_uri).to_lower() != expected_hash:
		return _failure("GLB SHA-256 does not match the pinned BuildDocument asset hash.")

	if str(asset.get("license", "")).strip_edges().is_empty():
		return _failure("Asset license metadata is required.")
	if str(asset.get("source", "")).strip_edges().is_empty():
		return _failure("Asset source/provenance metadata is required.")

	var catalog_value: Variant = asset.get("surface_catalog", null)
	if not (catalog_value is Array) or (catalog_value as Array).is_empty():
		return _failure("A validated, non-empty surface catalog is required for editable GLB loading.")

	var gltf_document := GLTFDocument.new()
	var gltf_state := GLTFState.new()
	var import_error: Error = gltf_document.append_from_file(asset_uri, gltf_state)
	if import_error != OK:
		return _failure("Godot GLTF import failed: " + error_string(import_error))

	var scene_root: Node = gltf_document.generate_scene(gltf_state)
	if not (scene_root is Node3D):
		if scene_root != null:
			scene_root.free()
		return _failure("Imported GLB root must be a Node3D.")

	var inventory: Dictionary = GlbSurfaceCatalogScript.inspect_scene(scene_root)
	if not inventory.get("ok", false) or inventory.get("surfaces", []).is_empty():
		scene_root.free()
		return _failure("Imported GLB contains no inspectable mesh surfaces.")

	var binder = SurfaceMaterialBinderScript.new()
	var binder_result: Dictionary = binder.configure_from_build_document(scene_root, document)
	if not binder_result.get("ok", false):
		scene_root.free()
		return _failure("Surface binder rejected the catalog: " + str(binder_result.get("errors", [])))

	var parts_by_id: Dictionary = {}
	for surface_value in catalog_value:
		if not (surface_value is Dictionary):
			scene_root.free()
			return _failure("Surface catalog contains an invalid record.")
		var surface: Dictionary = surface_value
		var part_id := str(surface.get("part_id", "")).strip_edges()
		var surface_id := str(surface.get("surface_id", "")).strip_edges()
		if part_id.is_empty():
			continue
		if not parts_by_id.has(part_id):
			parts_by_id[part_id] = []
		parts_by_id[part_id].append(surface_id)

	if parts_by_id.is_empty():
		scene_root.free()
		return _failure("At least one catalog surface must map to a stable part_id.")

	var material_result := _apply_saved_surface_materials(document, binder)
	if not material_result.get("ok", false):
		scene_root.free()
		return _failure("Saved material state could not be applied: " + str(material_result.get("errors", [])))

	var part_ids: Array[String] = []
	for part_id in parts_by_id.keys():
		part_ids.append(str(part_id))
	part_ids.sort()
	return {
		"ok": true,
		"errors": [],
		"scene_root": scene_root,
		"surface_binder": binder,
		"parts_by_id": parts_by_id,
		"part_ids": part_ids,
		"surface_inventory": inventory.get("surfaces", []).duplicate(true)
	}

static func _apply_saved_surface_materials(document: Dictionary, binder) -> Dictionary:
	var customization: Dictionary = document.get("customization", {})
	var materials: Variant = customization.get("materials", [])
	if not (materials is Array):
		return {"ok": false, "errors": ["BuildDocument customization.materials must be an array."]}
	for record_value in materials:
		if not (record_value is Dictionary):
			continue
		var record: Dictionary = record_value
		var target_ids: Variant = record.get("target_surface_ids", [])
		if not (target_ids is Array) or target_ids.is_empty():
			continue
		var color_hex := str(record.get("base_color", ""))
		if not _is_hex_color(color_hex):
			return {"ok": false, "errors": ["Saved surface material contains an invalid base_color."]}
		var color := Color.from_string(color_hex, Color.WHITE)
		for surface_id_value in target_ids:
			var surface_id := str(surface_id_value)
			if not binder.has_surface(surface_id):
				return {"ok": false, "errors": ["Saved material references an unavailable surface: " + surface_id]}
			if binder.apply_surface_color(surface_id, color) == null:
				return {"ok": false, "errors": ["Surface does not support safe StandardMaterial3D editing: " + surface_id]}
	return {"ok": true, "errors": []}

static func _is_safe_local_glb_uri(value: String) -> bool:
	if not (value.begins_with("res://") or value.begins_with("user://")):
		return false
	if not value.to_lower().ends_with(".glb") or value.contains(":\u0000"):
		return false
	var relative_path := value.trim_prefix("res://").trim_prefix("user://")
	if relative_path.is_empty() or relative_path.begins_with("/") or relative_path.contains("\\"):
		return false
	for segment in relative_path.split("/", false):
		if segment == ".." or segment == "." or segment.is_empty():
			return false
	return true

static func _is_sha256(value: String) -> bool:
	var regex := RegEx.new()
	regex.compile("^[0-9a-f]{64}$")
	return regex.search(value) != null

static func _is_hex_color(value: String) -> bool:
	var regex := RegEx.new()
	regex.compile("^#[0-9A-Fa-f]{6}([0-9A-Fa-f]{2})?$")
	return regex.search(value) != null

static func _failure(message: String) -> Dictionary:
	return {"ok": false, "errors": [message]}
