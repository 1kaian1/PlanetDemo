extends Node2D

@onready var mesh_instance = get_node("/root/main/PlanetRotation/MeshInstance3D")
@onready var camera = get_node("/root/main/Camera3D")

func _process(delta):
	if mesh_instance and camera:
		var screen_pos : Vector2 = camera.unproject_position(mesh_instance.global_transform.origin)
		global_position = screen_pos
