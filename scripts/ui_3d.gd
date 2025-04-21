extends Node3D

# INFO:
# 
# Delta je doba v sekundách od minulého snímku. Proč je to důležité? Protože
# když děláš pohyb, rotaci, animaci... vždycky ji násobíš delta, aby to bylo
# nezávislé na FPS.

var rotation_quat : Quaternion = Quaternion.IDENTITY
var target_rotation : Quaternion = Quaternion.IDENTITY

var camera : Camera3D

var dragging : bool = false
var last_touch_pos : Vector2 = Vector2.ZERO
var rotation_speed : float = 0.5  # Rychlost interpolace (setrvačnost)

var active_touches : int = 0  # Sledování počtu aktivních dotyků

func _ready():
	camera = get_node("Camera3D")
	set_process_input(true)

func _process(_delta):
	
	# Plynulá interpolace rotace s setrvačností
	# Přibližuj se o rotation_speed % blíže k cíli každý snímek
	rotation_quat = rotation_quat.slerp(target_rotation, rotation_speed)
	
	# Aplikování rotace na všechny objekty ve scéně, ale ne na kameru
	var universal_rotation = rotation_quat.get_euler()
	for child in get_children():
		if child is Node3D and child != camera: # Platí i pro MeshInstance3D (EarthPlanet)
			child.rotation = universal_rotation
			
	# Kamera se bude dívat stále na bod [0, 0, 0] (střed scény)
	camera.look_at(Vector3.ZERO, Vector3.UP)

	#print(camera.position)

func _input(event):
	if event is InputEventScreenTouch:
		# Zaznamenáme, jestli je dotyk stisknutý nebo uvolněný
		if event.pressed:
			active_touches += 1  # Přidáme nový dotyk
		else:
			active_touches -= 1  # Odebereme dotyk, pokud byl uvolněn

		# Pokud máme více než 1 dotyk, ignorujeme další vstupy
		if active_touches > 1:
			return  # Pokud máme více než 1 dotyk, neprovádíme žádnou rotaci
			

		dragging = event.pressed
		last_touch_pos = event.position
		
		#print(event.position)

	elif event is InputEventScreenDrag and dragging:
		# Provádíme rotaci pouze pokud máme jeden dotyk na obrazovce
		if active_touches == 1:
			var delta : Vector2 = event.position - last_touch_pos
			last_touch_pos = event.position

			# Rotace kolem lokálních os X a Y
			var pitch : Quaternion = Quaternion(Vector3.RIGHT, delta.y * 0.01)
			var yaw : Quaternion = Quaternion(Vector3.UP, delta.x * 0.01)

			# Kombinování rotací
			target_rotation = pitch * yaw * rotation_quat
