extends MeshInstance3D

@onready var camera: Camera3D = get_node("/root/main/Camera3D")

var touches := {}
var last_distance := 0.0

func _input(event):
	# Dotyk prstu
	if event is InputEventScreenTouch:
		if event.pressed:
			touches[event.index] = event.position
		else:
			touches.erase(event.index)
			last_distance = 0.0

	# Pohyb prstu
	if event is InputEventScreenDrag:
		touches[event.index] = event.position

		if touches.size() == 2:
			var points = touches.values()
			var current_distance = points[0].distance_to(points[1])
			handle_pinch(current_distance)

func handle_pinch(current_distance: float):
	if last_distance == 0.0:
		last_distance = current_distance
		return

	var delta = current_distance - last_distance
	
	# citlivost zoomu
	zoom_camera(-delta * 0.4)

	last_distance = current_distance

func zoom_camera(amount: float):
	camera.translate_object_local(Vector3(0, 0, amount))
