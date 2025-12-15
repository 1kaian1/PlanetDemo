extends Node3D

@export var WINDOW_FIELD_RADIUS = 300

@onready var discovery_field = get_node("/root/main/UI3D/DiscoveryField")
@onready var coin_field = get_node("/root/main/UI3D/PlanetRotation/CoinField")
@onready var planet_rotation = get_node("/root/main/UI3D/PlanetRotation")
@onready var UI3D = get_node("/root/main/UI3D")

@onready var camera = get_node("/root/main/Camera3D")

@onready var coin_counter = get_node("/root/main/UI2D/Control/CoinBar/CoinCounter")

@onready var ui = $Control2


var target_position : Vector3
var lerp_speed : float = 5.0
var buttons_split := false
var distance : float = 0.0

func _ready():
	ui.discovery_mode_pressed.connect(_on_DiscoveryModeButton_pressed)
	ui.home_mode_pressed.connect(_on_HomeModeButton_pressed)
	ui.search_pressed.connect(_on_SearchButton_pressed)
	ui.exit_pressed.connect(_on_ExitButton_pressed)

	target_position = camera.position

	ui.set_ready_ui(true)
	discovery_field.visible = false
	
func _on_DiscoveryModeButton_pressed():
	
	target_position = Vector3(0, 0, 0)
	
	var planet_earth = get_node("/root/main/UI3D/PlanetRotation/PlanetEarth")
	planet_earth.fade_out()
	
	ui.set_discovery_ui(true)
	
	
	discovery_field.visible = true
	coin_field.visible = false
	
	#grid.move_child(search_button, 0)
	
func _on_HomeModeButton_pressed():
	
	target_position = Vector3(0, 0, 60)
	
	ui.set_home_ui(true)

	#build_button.visible = true

	coin_field.visible = false
	
	planet_rotation.rotation_speed = 0.0
	UI3D.rotation_speed = 0.02
	
func _on_ExitButton_pressed():
	

	
	distance = camera.position.length()
	
	ui.set_exit_ui(true)
	
	if distance < 50:
		
		target_position = Vector3(0, 0, 200)
		
		var planet_earth = get_node("/root/main/UI3D/PlanetRotation/PlanetEarth")
		planet_earth.fade_in()
		
		discovery_field.visible = false
		coin_field.visible = true
		
		ui.exit_discover_ui(true)
		
	else:
			
		target_position = Vector3(0, 0, 200)
		
		#build_button.visible = false

		coin_field.visible = true
		
		planet_rotation.rotation_speed = 0.2
		UI3D.rotation_speed = 0.1
		
func _process(delta):
	camera.position = camera.position.lerp(target_position, lerp_speed * delta)
		
		
func _on_SearchButton_pressed():
	
	ui.save_coins(-100)
	
	var pos = get_position_in_camera_view()
	var coin_node = Area3D.new()
	coin_node.position = pos
	discovery_field.add_child(coin_node)
	coin_node.look_at(Vector3.ZERO, Vector3.UP)

	var coin_sprite = Sprite3D.new()
	coin_sprite.texture = load("res://textures/red_circle_full.png")
	coin_sprite.scale = Vector3.ZERO
	coin_sprite.layers = 2
	coin_sprite.set_meta("type", "full")
	coin_node.add_child(coin_sprite)
		
	var coin_sprite2 = Sprite3D.new()
	coin_sprite2.texture = load("res://textures/red_circle_empty_dotted.png")
	coin_sprite2.scale = Vector3(28,28,28)
	coin_sprite2.layers = 2
	coin_sprite.set_meta("type", "empty")
	coin_node.add_child(coin_sprite2)

	var tween = create_tween()
	tween.tween_property(coin_sprite, "scale", Vector3(13.5,13.5,13.5), 5) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)
	
		
		
func get_position_in_camera_view():
	
	var rotation = UI3D.rotation_quat
	var world_direction = (rotation.inverse() * Vector3(0, 0, -1)).normalized()

	var position_on_sphere = world_direction * WINDOW_FIELD_RADIUS
	return position_on_sphere
