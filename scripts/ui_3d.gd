extends Node3D

var rotation_quat : Quaternion = Quaternion.IDENTITY
var angle_quat : Quaternion = Quaternion.IDENTITY
var target_rotation : Quaternion = Quaternion.IDENTITY
var dragging : bool = false
var last_touch_pos : Vector2 = Vector2.ZERO
var active_touches : int = 0

@export var rotation_speed : float = 0.1
@onready var camera = get_node("/root/main/Camera3D")

var scene_forward : Vector3 = Vector3.BACK

func _process(_delta):
	rotation_quat = rotation_quat.slerp(target_rotation, rotation_speed)
	
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
			
			


			
			# Vector3.RIGHT = vektor (1, 0, 0) = osa X (doprava).
			# Tohle říká: vytvoř quaternion, který reprezentuje rotaci kolem
			# osy X o úhel delta.y * 0.01 radiánů.
			var pitch : Quaternion = Quaternion(Vector3.RIGHT, delta.y * 0.01)
			
			# Vector3.UP = vektor (0, 1, 0) = osa Y (nahoru).
			# Tohle říká: vytvoř quaternion, který reprezentuje rotaci kolem
			# osy X o úhel delta.y * 0.01 radiánů.
			var yaw : Quaternion = Quaternion(Vector3.UP, delta.x * 0.01)
			# chybí rotace kolem osy z, což v kontextu zpracovávání pohybu prstu
			# po displayi nehraje roli, ale v kontextu printování do prostoru velikou!
			
			target_rotation = pitch * yaw * rotation_quat
		
