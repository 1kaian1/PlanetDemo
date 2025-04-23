extends Node3D

func _ready():
	add_child(create_axis(Vector3(1, 0, 0), Color.BLUE, Vector3(90, 0, 0)))   # X-axis
	add_child(create_axis(Vector3(0, 1, 0), Color.GREEN, Vector3(0, 0, 0))) # Y-axis
	add_child(create_axis(Vector3(0, 0, 1), Color.RED, Vector3(0, 0, 90)))  # Z-axis

func create_axis(direction: Vector3, color: Color, rotation: Vector3) -> MeshInstance3D:
	var axis_mesh = CylinderMesh.new()
	axis_mesh.top_radius = 1   # Nastavení šířky horní části
	axis_mesh.bottom_radius = 1 # Nastavení šířky spodní části
	axis_mesh.height = 10000.0   # Nastavení délky osy

	# Materiál pro barvu osy
	var material = StandardMaterial3D.new()
	material.albedo_color = color

	var axis_instance = MeshInstance3D.new()
	axis_instance.mesh = axis_mesh
	axis_instance.material_override = material

	# Rotace podle příslušné osy
	axis_instance.rotate_object_local(Vector3(1, 0, 0), deg_to_rad(rotation.x))
	axis_instance.rotate_object_local(Vector3(0, 1, 0), deg_to_rad(rotation.y))
	axis_instance.rotate_object_local(Vector3(0, 0, 1), deg_to_rad(rotation.z))

	return axis_instance
