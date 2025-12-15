extends Node3D

var rotation_quat : Quaternion = Quaternion.IDENTITY
@onready var UI3D = get_node("/root/main/UI3D")
@export var rotation_speed : float = 0.1


func _process(_delta):
	for area in get_children():
		if area is Area3D:
			for sprite in area.get_children():
				if sprite is Sprite3D and sprite.has_meta("type") and sprite.get_meta("type") == "full":
					print("Sprite:", sprite.name, "Scale:", sprite.scale)
