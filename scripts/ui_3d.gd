extends Node3D

var rotation_quat : Quaternion = Quaternion.IDENTITY
var target_rotation : Quaternion = Quaternion.IDENTITY
var dragging : bool = false
var last_touch_pos : Vector2 = Vector2.ZERO
var active_touches : int = 0

@export var rotation_speed : float = 0.1
@onready var camera = get_node("/root/main/Camera3D")

func _process(_delta):
	
	rotation_quat = rotation_quat.slerp(target_rotation, rotation_speed)
	
	#var basis_from_rotation = Basis(rotation_quat)
	#var camera_in_world_space = basis_from_rotation * camera.position
	#print("Pozice kamery: ", camera_in_world_space)
#
#
	#var inverse_rotation = rotation_quat.inverse()
	#var camera_world_basis = Basis(inverse_rotation)
	#var camera_world_rotation = camera_world_basis.get_euler()
#
	#print("Rotace kamery ve světě (stupně): ",
		  #"X: ", rad_to_deg(camera_world_rotation.x),
		  #", Y: ", rad_to_deg(camera_world_rotation.y),
		  #", Z: ", rad_to_deg(camera_world_rotation.z))

	
	
	var universal_rotation = rotation_quat.get_euler()
	for child in get_children():
		child.rotation = universal_rotation

func _input(event):
	
	if event is InputEventScreenTouch:
		
		if event.pressed:
			active_touches += 1
		else:
			active_touches -= 1
			
		if active_touches > 1:
			return
			
		dragging = event.pressed
		last_touch_pos = event.position
		
	elif event is InputEventScreenDrag and dragging:
		
		if active_touches == 1:
			
			var delta : Vector2 = event.position - last_touch_pos
			last_touch_pos = event.position
			
			var pitch : Quaternion = Quaternion(Vector3.RIGHT, delta.y * 0.01)
			var yaw : Quaternion = Quaternion(Vector3.UP, delta.x * 0.01)
			
			target_rotation = pitch * yaw * rotation_quat
		
