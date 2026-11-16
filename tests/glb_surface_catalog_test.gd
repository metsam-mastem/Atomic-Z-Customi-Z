extends SceneTree

const BuildDocumentScript = preload("res://scripts/build_document.gd")
const CatalogScript = preload("res://scripts/glb_surface_catalog.gd")
const BinderScript = preload("res://scripts/surface_material_binder.gd")

var _failed := false

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var root_node := Node3D.new()
	root_node.name = "ImportedBike"
	root.add_child(root_node)
	var body := Node3D.new()
	body.name = "Body"
	root_node.add_child(body)
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "VisualMesh"
	body.add_child(mesh_instance)

	var mesh := ArrayMesh.new()
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array([Vector3.ZERO, Vector3.RIGHT, Vector3.UP])
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var imported_body := StandardMaterial3D.new()
	imported_body.resource_name = "ImportedBodyPaint"
	imported_body.albedo_color = Color("#345678")
	imported_body.metallic = 0.31
	imported_body.roughness = 0.43
	var imported_trim := StandardMaterial3D.new()
	imported_trim.resource_name = "ImportedTrim"
	imported_trim.metallic = 0.72
	imported_trim.roughness = 0.28
	mesh.surface_set_material(0, imported_body)
	mesh.surface_set_material(1, imported_trim)
	mesh_instance.mesh = mesh

	var inventory: Dictionary = CatalogScript.inspect_scene(root_node)
	_assert(inventory.get("ok", false), "A valid imported scene must be inventoried.")
	_assert(inventory.get("surfaces", []).size() == 2, "Inventory must enumerate every mesh surface.")
	_assert(inventory["surfaces"][0].get("node_path") == "Body/VisualMesh", "Inventory must use root-relative node paths.")
	_assert(inventory["surfaces"][1].get("surface_index") == 1, "Inventory must preserve exact surface indices.")
	_assert(inventory["surfaces"][0].get("source_material_name") == "ImportedBodyPaint", "Inventory must report the source material name.")

	var definitions := [
		{"surface_id": "body.paint", "node_path": "Body/VisualMesh", "surface_index": 0, "part_id": "fuel_tank"},
		{"surface_id": "body.trim", "node_path": "Body/VisualMesh", "surface_index": 1, "part_id": "fuel_tank"}
	]
	var attached: Dictionary = CatalogScript.attach_to_document(
		BuildDocumentScript.create_default("test-bike", "Test Bike"),
		root_node,
		definitions
	)
	_assert(attached.get("ok", false), "A valid stable surface manifest must attach atomically to BuildDocument.")
	var document: Dictionary = attached.get("document", {})
	_assert(document.get("asset", {}).get("surface_catalog", []).size() == 2, "BuildDocument must contain the canonical surface catalog.")
	_assert(BuildDocumentScript.validate(document).get("ok", false), "The document with a valid surface catalog must validate.")
	var legacy_document := document.duplicate(true)
	legacy_document["asset"].erase("surface_catalog")
	_assert(BuildDocumentScript.validate(legacy_document).get("ok", false), "Older BuildDocuments without surface_catalog must remain valid.")
	var before_rejected_attach := document.duplicate(true)
	var rejected_attach: Dictionary = CatalogScript.attach_to_document(document, root_node, [
		{"surface_id": "bad", "node_path": "Body/VisualMesh", "surface_index": 99}
	])
	_assert(not rejected_attach.get("ok", true), "Invalid catalog attachment must be rejected.")
	_assert(document == before_rejected_attach, "Rejected catalog attachment must not mutate the original BuildDocument.")

	var invalid_target := document.duplicate(true)
	invalid_target["customization"]["materials"] = [{
		"material_id": "paint:missing",
		"target_surface_ids": ["body.unknown"],
		"base_color": "#AABBCC"
	}]
	_assert(not BuildDocumentScript.validate(invalid_target).get("ok", true), "Material records must not target unknown surface IDs.")

	var duplicate_id: Dictionary = CatalogScript.validate_manifest(root_node, [
		{"surface_id": "same", "node_path": "Body/VisualMesh", "surface_index": 0},
		{"surface_id": "same", "node_path": "Body/VisualMesh", "surface_index": 1}
	])
	_assert(not duplicate_id.get("ok", true), "Duplicate stable surface IDs must be rejected.")
	var duplicate_slot: Dictionary = CatalogScript.validate_manifest(root_node, [
		{"surface_id": "one", "node_path": "Body/VisualMesh", "surface_index": 0},
		{"surface_id": "two", "node_path": "Body/VisualMesh", "surface_index": 0}
	])
	_assert(not duplicate_slot.get("ok", true), "Two IDs must not alias one mesh surface.")
	var missing_surface: Dictionary = CatalogScript.validate_manifest(root_node, [
		{"surface_id": "missing", "node_path": "Body/VisualMesh", "surface_index": 9}
	])
	_assert(not missing_surface.get("ok", true), "Out-of-range surface indices must be rejected.")

	var binder = BinderScript.new()
	var configured: Dictionary = binder.configure_from_build_document(root_node, document)
	_assert(configured.get("ok", false), "Binder must consume the catalog from the canonical BuildDocument.")
	var edited: bool = binder.set_surface_color(document, "body.paint", Color("#ABCDEF"))
	_assert(edited, "A valid surface color edit must update both the runtime surface and BuildDocument.")
	_assert(document["customization"]["materials"].size() == 1, "Surface edit must create one canonical material record.")
	_assert(document["customization"]["materials"][0].get("target_surface_ids") == ["body.paint"], "Material record must target the stable surface ID.")
	_assert(document["customization"]["materials"][0].get("base_color") == "#ABCDEF", "Material record must persist the selected color.")
	var applied := mesh_instance.get_surface_override_material(0) as StandardMaterial3D
	_assert(applied != null and applied.albedo_color == Color("#ABCDEF"), "The selected runtime surface must show the persisted color.")
	_assert(mesh_instance.get_surface_override_material(1) == null, "Unselected surfaces must remain untouched.")
	_assert(mesh.surface_get_material(0) == imported_body and imported_body.albedo_color == Color("#345678"), "Imported PBR source materials must remain unchanged.")
	_assert(mesh.surface_get_material(1) == imported_trim, "Unselected imported PBR material resource identity must remain unchanged.")
	_assert(is_equal_approx(imported_trim.metallic, 0.72), "Unselected imported PBR metallic value must remain unchanged within floating-point tolerance.")
	_assert(is_equal_approx(imported_trim.roughness, 0.28), "Unselected imported PBR roughness value must remain unchanged within floating-point tolerance.")
	_assert(is_equal_approx(applied.metallic, imported_body.metallic) and is_equal_approx(applied.roughness, imported_body.roughness), "The edited duplicate must preserve imported PBR properties.")
	_assert(binder.set_surface_color(document, "body.paint", Color("#FEDCBA")), "A second color edit must update the same canonical surface material record.")
	_assert(document["customization"]["materials"].size() == 1, "Repeated surface edits must not create duplicate material records.")
	var reapplied := mesh_instance.get_surface_override_material(0) as StandardMaterial3D
	_assert(reapplied != null and reapplied.albedo_color == Color("#FEDCBA"), "The second edit must update the owned surface override.")
	_assert(is_equal_approx(reapplied.metallic, imported_body.metallic) and is_equal_approx(reapplied.roughness, imported_body.roughness), "Repeated edits must retain imported PBR properties.")

	if not _failed:
		print("PASS: GLB surface inventory, stable manifest, BuildDocument contract and isolated material edit.")
	quit(1 if _failed else 0)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		_failed = true
		push_error(message)
