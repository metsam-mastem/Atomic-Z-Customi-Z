extends Node3D
class_name BikeAssembly

const GlbVehicleRuntimeScript = preload("res://scripts/glb_vehicle_runtime.gd")

var _parts: Dictionary = {}
var _body_materials: Array[StandardMaterial3D] = []
var _is_exploded := false
var _build_document: Dictionary = {}
var _is_imported_model := false
var _imported_root: Node3D
var _imported_binder
var _imported_parts: Dictionary = {}
var _imported_catalog: Array = []

func configure_build_document(document: Dictionary) -> void:
	_build_document = document

func _ready() -> void:
	var asset: Dictionary = _build_document.get("asset", {})
	var asset_uri := str(asset.get("uri", "")).strip_edges()
	if not asset_uri.is_empty():
		var import_result: Dictionary = GlbVehicleRuntimeScript.instantiate_from_document(_build_document)
		if import_result.get("ok", false):
			_is_imported_model = true
			_imported_root = import_result["scene_root"]
			_imported_binder = import_result["surface_binder"]
			_imported_parts = import_result["parts_by_id"]
			_imported_catalog = _build_document.get("asset", {}).get("surface_catalog", []).duplicate(true)
			_imported_root.name = "ImportedVehicle"
			add_child(_imported_root)
			_sync_imported_document_parts()
			return
		push_warning("Imported GLB rejected; procedural placeholder retained: " + str(import_result.get("errors", [])))
	var requested_mode := str(_build_document.get("assembly", {}).get("mode", "stock"))
	_build_placeholder()
	_sync_document_parts()
	_apply_document_materials()
	set_exploded(requested_mode == "exploded")

func is_imported_model() -> bool:
	return _is_imported_model

func supports_exploded_view() -> bool:
	return not _is_imported_model

func _sync_imported_document_parts() -> void:
	if _build_document.is_empty():
		return
	var part_records: Array = []
	for part_id in _imported_parts.keys():
		part_records.append({
			"part_id": str(part_id),
			"display_name": str(part_id).replace("_", " ").capitalize(),
			"surface_ids": _imported_parts[part_id].duplicate(),
			"asset_status": "glb_catalogued"
		})
	_build_document["assembly"]["parts"] = part_records
	_build_document["assembly"]["mode"] = "stock"

func _get_imported_surface_material(surface_id: String) -> Material:
	if _imported_root == null:
		return null
	for surface_value in _imported_catalog:
		if not (surface_value is Dictionary):
			continue
		var surface: Dictionary = surface_value
		if str(surface.get("surface_id", "")) != surface_id:
			continue
		var target := _imported_root.get_node_or_null(NodePath(str(surface.get("node_path", ""))))
		if not (target is MeshInstance3D):
			return null
		var mesh_instance: MeshInstance3D = target
		if mesh_instance.mesh == null:
			return null
		var surface_index := int(surface.get("surface_index", -1))
		if surface_index < 0 or surface_index >= mesh_instance.mesh.get_surface_count():
			return null
		var override_material := mesh_instance.get_surface_override_material(surface_index)
		return override_material if override_material != null else mesh_instance.mesh.surface_get_material(surface_index)
	return null

func set_exploded(enabled: bool) -> void:
	if _is_imported_model:
		_is_exploded = false
		if not _build_document.is_empty():
			_build_document["assembly"]["mode"] = "stock"
		return
	_is_exploded = enabled
	if not _build_document.is_empty():
		_build_document["assembly"]["mode"] = "exploded" if enabled else "stock"
	for part_id in _parts:
		var item: Dictionary = _parts[part_id]
		var part_node: Node3D = item["node"]
		var home: Vector3 = item["home"]
		var offset: Vector3 = item["explode"]
		part_node.position = home + (offset if enabled else Vector3.ZERO)

func toggle_exploded() -> bool:
	if not supports_exploded_view():
		return false
	set_exploded(not _is_exploded)
	return _is_exploded

func set_body_color(color: Color) -> void:
	for part_id in ["fuel_tank", "front_fairing", "tail_fairing"]:
		set_part_color(part_id, color)

func get_part_ids() -> Array[String]:
	var part_ids: Array[String] = []
	if _is_imported_model:
		for part_id in _imported_parts.keys():
			part_ids.append(str(part_id))
		part_ids.sort()
		return part_ids
	for part_id in _parts.keys():
		part_ids.append(str(part_id))
	part_ids.sort()
	return part_ids

func get_part_display_name(part_id: String) -> String:
	if _is_imported_model and _imported_parts.has(part_id):
		return part_id.replace("_", " ").capitalize()
	if not _parts.has(part_id):
		return ""
	return part_id.replace("_", " ").capitalize()

func get_part_color(part_id: String) -> Color:
	if _is_imported_model:
		if not _imported_parts.has(part_id):
			return Color.TRANSPARENT
		for surface_id_value in _imported_parts[part_id]:
			var imported_material := _get_imported_surface_material(str(surface_id_value))
			if imported_material is StandardMaterial3D:
				return (imported_material as StandardMaterial3D).albedo_color
		return Color.TRANSPARENT
	if not _parts.has(part_id):
		return Color.TRANSPARENT
	var material: StandardMaterial3D = _parts[part_id].get("material")
	if material == null:
		return Color.TRANSPARENT
	return material.albedo_color

func set_part_color(part_id: String, color: Color) -> bool:
	if _is_imported_model:
		if not _imported_parts.has(part_id):
			return false
		var target_surface_ids: Array = _imported_parts[part_id]
		if target_surface_ids.is_empty():
			return false
		for surface_id_value in target_surface_ids:
			var surface_id := str(surface_id_value)
			if not _imported_binder.has_surface(surface_id):
				return false
			if not (_get_imported_surface_material(surface_id) is StandardMaterial3D):
				return false
		for surface_id_value in target_surface_ids:
			if not _imported_binder.set_surface_color(_build_document, str(surface_id_value), color):
				return false
		return true
	if not _parts.has(part_id):
		return false
	var material: StandardMaterial3D = _parts[part_id].get("material")
	if material == null:
		return false
	material.albedo_color = color

	if not _build_document.is_empty():
		var materials: Array = _build_document["customization"].get("materials", [])
		var material_id := "paint:" + part_id
		var color_hex := "#" + color.to_html(false).to_upper()
		var found := false
		for index in range(materials.size()):
			if materials[index] is Dictionary and str(materials[index].get("material_id", "")) == material_id:
				materials[index]["target_part_ids"] = [part_id]
				materials[index]["base_color"] = color_hex
				found = true
				break
		if not found:
			materials.append({
				"material_id": material_id,
				"target_part_ids": [part_id],
				"base_color": color_hex
			})
		_build_document["customization"]["materials"] = materials
	return true

func _build_placeholder() -> void:
	_add_box("main_frame", Vector3(1.35, 0.16, 0.22), Vector3.ZERO, Color("#343d49"), 0.72, 0.36, Vector3(0.0, 0.0, 0.34))
	_add_box("engine_block", Vector3(0.55, 0.48, 0.43), Vector3(0.0, 0.69, 0.0), Color("#6b737c"), 0.82, 0.3, Vector3(0.0, -0.2, 0.55))
	_add_box("swingarm", Vector3(0.95, 0.12, 0.12), Vector3(-0.68, 0.58, 0.0), Color("#65717d"), 0.85, 0.28, Vector3(-0.18, -0.18, -0.48))
	_add_wheel("rear_wheel", Vector3(-1.15, 0.48, 0.0), 0.43, Vector3(-0.25, -0.12, -0.25))
	_add_wheel("front_wheel", Vector3(1.15, 0.48, 0.0), 0.43, Vector3(0.25, -0.12, 0.25))
	_add_box("front_fork_left", Vector3(0.1, 0.88, 0.1), Vector3(0.98, 0.96, -0.16), Color("#aeb8c2"), 0.88, 0.22, Vector3(0.28, 0.18, -0.28))
	_add_box("front_fork_right", Vector3(0.1, 0.88, 0.1), Vector3(0.98, 0.96, 0.16), Color("#aeb8c2"), 0.88, 0.22, Vector3(0.28, 0.18, 0.28))
	_add_box("fuel_tank", Vector3(0.72, 0.42, 0.52), Vector3(0.05, 1.32, 0.0), Color("#e53b36"), 0.38, 0.24, Vector3(0.0, 0.38, 0.72), true)
	_add_box("front_fairing", Vector3(0.42, 0.55, 0.56), Vector3(0.82, 1.27, 0.0), Color("#e53b36"), 0.32, 0.25, Vector3(0.38, 0.3, 0.0), true)
	_add_box("tail_fairing", Vector3(0.55, 0.26, 0.44), Vector3(-0.72, 1.34, 0.0), Color("#e53b36"), 0.32, 0.25, Vector3(-0.38, 0.28, 0.0), true)
	_add_box("seat", Vector3(0.72, 0.13, 0.42), Vector3(-0.35, 1.48, 0.0), Color("#171b21"), 0.08, 0.78, Vector3(-0.22, 0.42, 0.0))
	_add_box("exhaust", Vector3(0.82, 0.13, 0.16), Vector3(-0.35, 0.63, 0.34), Color("#b5bdc5"), 0.94, 0.2, Vector3(-0.35, -0.35, 0.45))
	_add_box("handlebar", Vector3(0.62, 0.07, 0.12), Vector3(0.78, 1.72, 0.0), Color("#252b33"), 0.78, 0.32, Vector3(0.35, 0.55, 0.0))
	_add_box("headlight", Vector3(0.12, 0.18, 0.34), Vector3(1.12, 1.35, 0.0), Color("#d9f3ff"), 0.1, 0.18, Vector3(0.55, 0.42, 0.0))
	_add_box("radiator", Vector3(0.22, 0.38, 0.48), Vector3(0.42, 0.82, 0.0), Color("#20262d"), 0.55, 0.5, Vector3(0.2, -0.32, 0.52))

func _add_wheel(part_id: String, at: Vector3, radius: float, explode_offset: Vector3) -> void:
	var wheel_mesh := CylinderMesh.new()
	wheel_mesh.top_radius = radius
	wheel_mesh.bottom_radius = radius
	wheel_mesh.height = 0.22
	var wheel_material := StandardMaterial3D.new()
	wheel_material.albedo_color = Color("#15191e")
	wheel_material.roughness = 0.92
	_add_mesh_part(part_id, wheel_mesh, at, wheel_material, explode_offset, Vector3(PI / 2.0, 0.0, 0.0), false)
	var wheel_root: Node3D = _parts[part_id]["node"]
	var rim_mesh := CylinderMesh.new()
	rim_mesh.top_radius = radius * 0.62
	rim_mesh.bottom_radius = radius * 0.62
	rim_mesh.height = 0.18
	var rim_material := StandardMaterial3D.new()
	rim_material.albedo_color = Color("#8995a3")
	rim_material.metallic = 0.88
	rim_material.roughness = 0.24
	var rim_visual := MeshInstance3D.new()
	rim_visual.name = "RimVisual"
	rim_visual.mesh = rim_mesh
	rim_visual.rotation = Vector3.ZERO
	rim_visual.material_override = rim_material
	wheel_root.add_child(rim_visual)
	_parts[part_id.replace("_wheel", "_rim")] = {
		"node": wheel_root,
		"mesh_instance": rim_visual,
		"material": rim_material,
		"home": at,
		"explode": explode_offset
	}

func _add_box(part_id: String, dimensions: Vector3, at: Vector3, color: Color, metallic: float, roughness: float, explode_offset: Vector3, is_body: bool = false) -> void:
	var box := BoxMesh.new()
	box.size = dimensions
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = roughness
	_add_mesh_part(part_id, box, at, material, explode_offset, Vector3.ZERO, is_body)

func _add_mesh_part(part_id: String, mesh: Mesh, at: Vector3, material: StandardMaterial3D, explode_offset: Vector3, rotation: Vector3, is_body: bool) -> void:
	var part_root := Node3D.new()
	part_root.name = part_id
	part_root.position = at
	part_root.rotation = rotation
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "VisualMesh"
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	part_root.add_child(mesh_instance)
	add_child(part_root)
	_parts[part_id] = {"node": part_root, "mesh_instance": mesh_instance, "material": material, "home": at, "explode": explode_offset}
	if is_body:
		_body_materials.append(material)

func _apply_document_materials() -> void:
	if _build_document.is_empty():
		return
	var saved_materials: Array = _build_document.get("customization", {}).get("materials", []).duplicate(true)
	for record_value in saved_materials:
		if not (record_value is Dictionary):
			continue
		var record: Dictionary = record_value
		var color_hex := str(record.get("base_color", ""))
		if not color_hex.begins_with("#"):
			continue
		var color := Color.from_string(color_hex, Color.TRANSPARENT)
		if color == Color.TRANSPARENT:
			continue
		var target_part_ids: Variant = record.get("target_part_ids", [])
		if not (target_part_ids is Array):
			continue
		for part_id_value in target_part_ids:
			var part_id := str(part_id_value)
			if _parts.has(part_id):
				var material: StandardMaterial3D = _parts[part_id].get("material")
				if material != null:
					material.albedo_color = color

func _sync_document_parts() -> void:
	if _build_document.is_empty():
		return
	var part_records: Array = []
	for part_id in _parts.keys():
		var item: Dictionary = _parts[part_id]
		var home: Vector3 = item["home"]
		var explode_offset: Vector3 = item["explode"]
		part_records.append({
			"part_id": str(part_id),
			"display_name": str(part_id).replace("_", " ").capitalize(),
			"home_position_m": [home.x, home.y, home.z],
			"explode_offset_m": [explode_offset.x, explode_offset.y, explode_offset.z],
			"asset_status": "placeholder_geometry"
		})
	_build_document["assembly"]["parts"] = part_records
	_build_document["assembly"]["mode"] = "stock"
