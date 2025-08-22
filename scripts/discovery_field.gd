extends Node3D

@onready var UI3D = get_node("/root/main/UI3D")

func _process(_delta):
	var rotation_quat = UI3D.rotation_quat
	rotation = rotation_quat.get_euler()
