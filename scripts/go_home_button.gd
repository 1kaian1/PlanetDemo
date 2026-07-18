extends Button

@export var camera_path: NodePath
@export var min_distance := 60.0
@export var max_distance := 80.0

var camera: Camera3D

func _ready():
	pressed.connect(_on_pressed)
	camera = get_node(camera_path)

func _process(delta):
	if camera == null:
		return

	var distance = camera.global_transform.origin.length()
	visible = distance >= min_distance and distance <= max_distance

func _on_pressed():
	get_tree().change_scene_to_file("res://scenes/WORLD2D.tscn")
