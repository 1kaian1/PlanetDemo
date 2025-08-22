extends Camera3D

# === Nastavitelné parametry ===
@export var target: Node3D         # Cílový objekt, na který se kamera dívá
@export var distance: float = 5.0  # Vzdálenost kamery od cíle
@export var sensitivity: float = 0.01
@export var min_distance := 1.0
@export var max_distance := 20.0
@export var min_theta := 0.01
@export var max_theta := PI - 0.01

# === Vnitřní stav ===
var theta := PI / 2.0  # Vertikální úhel (nahoru/dolů)
var phi := 0.0         # Horizontální úhel (doleva/doprava)

func _ready():
	if target == null:
		push_error("OrbitCamera potřebuje mít nastavený target (cílový Node3D).")
	_update_camera_position()

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		phi -= event.relative.x * sensitivity
		theta -= event.relative.y * sensitivity
		theta = clamp(theta, min_theta, max_theta)
		_update_camera_position()

	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			distance = max(min_distance, distance - 0.5)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			distance = min(max_distance, distance + 0.5)
		_update_camera_position()

func _update_camera_position():
	if target == null:
		return

	# Převod sférických souřadnic na 3D pozici kamery
	var x = distance * sin(theta) * cos(phi)
	var y = distance * cos(theta)
	var z = distance * sin(theta) * sin(phi)

	var cam_pos = target.global_transform.origin + Vector3(x, y, z)
	global_transform.origin = cam_pos
	look_at(target.global_transform.origin, Vector3.UP)
