extends Node3D
class_name BikeAssembly

var _parts: Dictionary = {}
var _body_materials: Array[StandardMaterial3D] = []
var _is_exploded := false
var _build_document: Dictionary = {}

func configure_build_document(document: Dictionary) -> void:
	_build_document = document

func _ready() -> void:
	_build_placeholder()
	_sync_document_parts()

func set_exploded(enabled: bool) -> void:
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
	set_exploded(not _is_exploded)
	return _is_exploded

func set_body_color(color: Color) -> void:
	if not _build_document.is_empty():
		_build_document["customization"]["materials"] = [{"material_id": "body-paint", "target_part_ids": ["fuel_tank", "front_fairing", "tail_fairing"], "base_color": "#" + color.to_html(false).to_upper()}]
	for material in _body_materials:
		material.albedo_color = color

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
	_add_mesh_part(part_id, wheel_mesh, at, wheel_material, explode_offset, Vector3(0.0, 0.0, PI / 2.0), false)

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
	_parts[part_id] = {"node": part_root, "home": at, "explode": explode_offset}
	if is_body:
		_body_materials.append(material)

func _sync_document_parts() -> void:
	if _build_document.is_empty():
		return
	var part_records: Array = []
	for part_id in _parts.keys():
		var item: Dictionary = _parts[part_id]
		part_records.append({
			"part_id": str(part_id),
			"display_name": str(part_id).replace("_", " ").capitalize(),
			"home_position_m": (item["home"] as Vector3).to_array(),
			"explode_offset_m": (item["explode"] as Vector3).to_array(),
			"asset_status": "placeholder_geometry"
		})
	_build_document["assembly"]["parts"] = part_records
	_build_document["assembly"]["mode"] = "stock"
