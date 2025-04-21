extends Node3D

@onready var discover_button = get_node("/root/main/UI2D/Control/MarginContainer/GridContainer/DiscoverButton")
@onready var search_button = get_node("/root/main/UI2D/Control/MarginContainer/GridContainer/SearchButton")
@onready var camera = get_node("/root/main/UI3D/Camera3D")
@onready var grid = get_node("/root/main/UI2D/Control/MarginContainer/GridContainer")
@onready var search_circle = get_node("/root/main/UI2D/Control/MarginContainer2")
@onready var coin_field = get_node("/root/main/UI3D/Node3D/CoinField")

var target_position : Vector3
var lerp_speed : float = 5.0  # Rychlost interpolace
var buttons_split := false

func _ready():
	discover_button.connect("pressed", Callable(self, "_on_DiscoverButton_pressed"))
	target_position = camera.position

	# Na začátku skryjeme menší tlačítka
	search_button.visible = false
	search_circle.visible = false	


func _on_DiscoverButton_pressed():
	var current_position = camera.position
	var distance = current_position.length()
	

	if distance < 50:
		# Přiblížení
		target_position = Vector3(0, 0, 200)
		
		grid.columns = 1
		
		search_button.visible = false
		
		discover_button.text = "Discover"	
		
		search_circle.visible = false	
		
		coin_field.visible = true
		
	else:
		
		coin_field.visible = false
		
		search_button.visible = true
		
		search_circle.visible = true
		
		print(search_circle)
		
		#search_circle.visible = false
		#search_circle.modulate.a = 0
		#search_circle.hide()
	
		
		# Oddálení
		target_position = Vector3(0, 0, 1)
				
		grid.columns = 2
		
		discover_button.text = "X"
		
		if not buttons_split:
			buttons_split = true
			search_button.visible = true
			
		grid.move_child(search_button, 0)
			

	print(distance)

			


func _process(delta):
	camera.position = camera.position.lerp(target_position, lerp_speed * delta)
