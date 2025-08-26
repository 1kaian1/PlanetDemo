extends Node3D

@export var WINDOW_FIELD_RADIUS = 300

@onready var discovery_mode_button = get_node("Control/MarginContainer/GridContainer/DiscoveryModeButton")
@onready var home_mode_button = get_node("Control/MarginContainer/GridContainer/HomeModeButton")
@onready var search_button = get_node("Control/MarginContainer/GridContainer/SearchButton")
@onready var exit_button = get_node("Control/MarginContainer/GridContainer/ExitButton")

@onready var search_area_indicator = get_node("Control/DiscoveryMode/SearchAreaIndicator")

@onready var discovery_field = get_node("/root/main/SubViewport/DiscoveryField")
@onready var coin_field = get_node("/root/main/UI3D/PlanetRotation/CoinField")
@onready var planet_rotation = get_node("/root/main/UI3D/PlanetRotation")
@onready var UI3D = get_node("/root/main/UI3D")

@onready var camera = get_node("/root/main/Camera3D")

@onready var coin_counter = get_node("/root/main/UI2D/Control/CoinBar/CoinCounter")
@onready var price_label = get_node("/root/main/UI2D/Control/DiscoveryMode/PriceLabel")



var target_position : Vector3
var lerp_speed : float = 5.0
var buttons_split := false
var distance : float = 0.0

func _ready():
	
	discovery_mode_button.connect("pressed", Callable(self, "_on_DiscoveryModeButton_pressed"))
	home_mode_button.connect("pressed", Callable(self, "_on_HomeModeButton_pressed"))
	search_button.connect("pressed", Callable(self, "_on_SearchButton_pressed"))
	exit_button.connect("pressed", Callable(self, "_on_ExitButton_pressed"))
	
	target_position = camera.position

	search_button.visible = false
	exit_button.visible = false
	search_area_indicator.visible = false
	
	discovery_field.visible = false
	
	price_label.visible = false
	
func _on_DiscoveryModeButton_pressed():
	
	target_position = Vector3(0, 0, 0)
	
	var planet_earth = get_node("/root/main/UI3D/PlanetRotation/PlanetEarth")
	planet_earth.fade_out()
	
	search_button.visible = true
	exit_button.visible = true
	
	discovery_mode_button.visible = false
	home_mode_button.visible = false
	
	price_label.visible = true
	
	discovery_field.visible = true
	coin_field.visible = false
	search_area_indicator.visible = true
	
	#grid.move_child(search_button, 0)
	
func _on_HomeModeButton_pressed():
	
	target_position = Vector3(0, 0, 60)
	
	#build_button.visible = true
	exit_button.visible = true
	
	home_mode_button.visible = false
	coin_field.visible = false
	
	planet_rotation.rotation_speed = 0.0
	UI3D.rotation_speed = 0.02
	
func _on_ExitButton_pressed():
	

	
	distance = camera.position.length()
	
	if distance < 50:
		
		target_position = Vector3(0, 0, 200)
		
		var planet_earth = get_node("/root/main/UI3D/PlanetRotation/PlanetEarth")
		planet_earth.fade_in()
		
		search_button.visible = false
		exit_button.visible = false
		
		discovery_mode_button.visible = true
		home_mode_button.visible = true
		
		discovery_field.visible = false
		coin_field.visible = true
		search_area_indicator.visible = false
		price_label.visible = false
		
	else:
			
		target_position = Vector3(0, 0, 200)
		
		#build_button.visible = false
		exit_button.visible = false
		search_button.visible = false # tohle je trochu prasárna

		
		discovery_mode_button.visible = true
		home_mode_button.visible = true
		coin_field.visible = true
		
		planet_rotation.rotation_speed = 0.2
		UI3D.rotation_speed = 0.1
	
func _process(delta):
	camera.position = camera.position.lerp(target_position, lerp_speed * delta)
		
		
func _on_SearchButton_pressed():
	
	coin_counter.save_coins(-100)
	
	var pos = get_position_in_camera_view()
	var coin_node = Area3D.new()
	coin_node.global_position = pos
	discovery_field.add_child(coin_node)
	

	var coin_sprite = Sprite3D.new()
	coin_sprite.texture = load("res://textures/red_circle_full.png")
	coin_sprite.scale = Vector3.ZERO
	coin_sprite.layers = 2
	coin_node.look_at(Vector3.ZERO, Vector3.UP)
	coin_node.add_child(coin_sprite)
		
	var coin_sprite2 = Sprite3D.new()
	coin_sprite2.texture = load("res://textures/red_circle_empty_dotted.png")
	coin_sprite2.scale = Vector3(13.5, 13.5, 13.5)
	coin_sprite2.layers = 2
	coin_node.look_at(Vector3.ZERO, Vector3.UP)
	coin_node.add_child(coin_sprite2)

	var tween = create_tween()
	tween.tween_property(coin_sprite, "scale", Vector3(13.7,13.7,13.7), 5) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)


func get_position_in_camera_view():
	var rotation = UI3D.rotation_quat

	var world_direction = (rotation.inverse() * Vector3(0, 0, -1)).normalized()

	var position_on_sphere = world_direction * WINDOW_FIELD_RADIUS
	return position_on_sphere
