extends Node3D

@export var radius: float = 70.0
@export var segments: int = 64
@export var normal: Vector3 = Vector3.UP

func _ready():
	create_circle()

func create_circle():
	var mesh_instance = MeshInstance3D.new()
	var immediate = ImmediateMesh.new()
	
	mesh_instance.mesh = immediate
	add_child(mesh_instance)
	
	immediate.clear_surfaces()
	immediate.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	
	# Najdi dva osové vektory vůči normále
	var axis_x = normal.cross(Vector3.UP)
	if axis_x.length() < 0.01:
		axis_x = normal.cross(Vector3.RIGHT)
	axis_x = axis_x.normalized()
	var axis_y = normal.cross(axis_x).normalized()
	
	for i in range(segments + 1): # uzavření kruhu
		var angle = TAU * float(i) / segments
		var point = radius * (cos(angle) * axis_x + sin(angle) * axis_y)
		immediate.surface_add_vertex(point)
		immediate.surface_set_color(Color(1.0, 1.0, 0.0))

	
	immediate.surface_end()
