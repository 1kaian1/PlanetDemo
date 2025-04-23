extends Node3D

@export var WINDOW_FIELD_RADIUS = 300

@onready var discovery_mode_button = get_node("Control/MarginContainer/GridContainer/DiscoveryModeButton")
@onready var home_mode_button = get_node("Control/MarginContainer/GridContainer/HomeModeButton")
@onready var search_button = get_node("Control/MarginContainer/GridContainer/SearchButton")
@onready var exit_button = get_node("Control/MarginContainer/GridContainer/ExitButton")

@onready var search_area_indicator = get_node("Control/DiscoveryMode/SearchAreaIndicator")
@onready var marked_area = get_node("Control/DiscoveryMode/MarkedArea")

#@onready var discovery_mode = get_node("Control/DiscoveryMode")
#@onready var home_mode = get_node("Control/HomeMode")

@onready var discovery_field = get_node("/root/main/UI3D/DiscoveryField")
@onready var coin_field = get_node("/root/main/UI3D/PlanetRotation/CoinField")
@onready var planet_rotation = get_node("/root/main/UI3D/PlanetRotation")
@onready var UI3D = get_node("/root/main/UI3D")

@onready var camera = get_node("/root/main/Camera3D")


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
	
	marked_area.visible = false
	
func _on_DiscoveryModeButton_pressed():
	
	target_position = Vector3(0, 0, 1)
	
	search_button.visible = true
	exit_button.visible = true
	
	discovery_mode_button.visible = false
	home_mode_button.visible = false
	
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
		
		search_button.visible = false
		exit_button.visible = false
		
		discovery_mode_button.visible = true
		home_mode_button.visible = true
		
		discovery_field.visible = false
		coin_field.visible = true
		search_area_indicator.visible = false
		
	else:
		
		target_position = Vector3(0, 0, 200)
		
		#build_button.visible = false
		exit_button.visible = false
		
		discovery_mode_button.visible = true
		home_mode_button.visible = true
		coin_field.visible = true
		
		planet_rotation.rotation_speed = 0.2
		UI3D.rotation_speed = 0.1
	
func _process(delta):
	camera.position = camera.position.lerp(target_position, lerp_speed * delta)

	
	
	
	
	
	
	
	
	
	
	

	
func _on_SearchButton_pressed():
	
	var target_node = get_node("/root/main/UI3D/DiscoveryField")
	
	var pos = get_position_in_camera_view()
	var coin_node = Area3D.new()
	print("POS:", pos)
	coin_node.position = pos
	target_node.add_child(coin_node)
	
	var coin_sprite = Sprite3D.new()
	coin_sprite.texture = load("res://textures/red_circle_rbg.png")
	coin_sprite.scale = Vector3(33,33,33)
	coin_node.look_at(Vector3.ZERO, Vector3.UP)
	coin_node.add_child(coin_sprite)

func get_position_in_camera_view():
	# Získání globálního směru kamery (basis.z je směr pohledu kamery)
	var rotation = UI3D.rotation_quat
	var basis = Basis(rotation)
	var camera_direction = basis.z.normalized()  # Směr kamery v prostoru (jednotkový vektor)
	
	var basis_from_rotation = Basis(rotation)
	var camera_in_world_space = basis_from_rotation * camera.position
	print("Pozice kamery ve světě: ", camera_in_world_space)


	var inverse_rotation = rotation.inverse()
	var camera_world_basis = Basis(inverse_rotation)
	var camera_world_rotation = camera_world_basis.get_euler()

	print("Rotace kamery ve světě (stupně): ",
		  "X: ", rad_to_deg(camera_world_rotation.x),
		  ", Y: ", rad_to_deg(camera_world_rotation.y),
		  ", Z: ", rad_to_deg(camera_world_rotation.z))
	
	
	
	#camera_direction.x -= camera_world_rotation.x
	#camera_direction.y -= camera_world_rotation
	camera_direction.z *= -1

	# Umístění kolečka přímo na směr pohledu kamery, ve vzdálenosti STAR_FIELD_RADIUS
	var position_on_sphere = camera_direction * WINDOW_FIELD_RADIUS
	return position_on_sphere
