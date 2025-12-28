extends Node3D

func _ready():
	add_child(create_axis(Color.BLUE, Vector3(90, 0, 0)))   # X
	add_child(create_axis(Color.GREEN, Vector3(0, 0, 0)))  # Y
	add_child(create_axis(Color.RED, Vector3(0, 0, 90)))   # Z

func create_axis(color: Color, rotation: Vector3) -> MeshInstance3D:
	var axis_mesh := CylinderMesh.new()
	axis_mesh.top_radius = 1
	axis_mesh.bottom_radius = 1
	axis_mesh.height = 10000.0

	var material := StandardMaterial3D.new()
	material.albedo_color = color

	# 🔥 EMISSION
	material.emission_enabled = true
	material.emission = color
	material.emission_energy = 3.0  # síla svitu (zkus 1–10)

	var axis_instance := MeshInstance3D.new()
	axis_instance.mesh = axis_mesh
	axis_instance.material_override = material

	axis_instance.rotate_object_local(Vector3.RIGHT, deg_to_rad(rotation.x))
	axis_instance.rotate_object_local(Vector3.UP, deg_to_rad(rotation.y))
	axis_instance.rotate_object_local(Vector3.FORWARD, deg_to_rad(rotation.z))

	return axis_instance
