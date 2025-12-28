extends Camera3D

@export var subviewport_camera: Camera3D

var touches := {}
var last_distance := -1.0
var target_zoom
var current_zoom
var min_zoom := 0.0
var max_zoom := 500.0
var zoom_speed := 0.8
var zoom_smooth := 6.0

func _ready():
	current_zoom = position.z
	target_zoom = current_zoom

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			touches[event.index] = event.position
		else:
			touches.erase(event.index)
			last_distance = -1.0

	if event is InputEventScreenDrag:
		if not touches.has(event.index):
			return

		touches[event.index] = event.position

		if touches.size() == 2:
			var keys := touches.keys()
			keys.sort()

			var p1: Vector2 = touches[keys[0]]
			var p2: Vector2 = touches[keys[1]]

			var dist := p1.distance_to(p2)

			if last_distance > 0.0:
				var pinch_delta := dist - last_distance

				if abs(pinch_delta) >= 2.0 and abs(pinch_delta) <= 30.0:
					target_zoom -= pinch_delta * zoom_speed
					target_zoom = clamp(target_zoom, min_zoom, max_zoom)

			last_distance = dist

func _process(delta):
	current_zoom = lerp(current_zoom, target_zoom, delta * zoom_smooth)
	position.z = current_zoom
	
	if subviewport_camera:
		subviewport_camera.transform = transform
