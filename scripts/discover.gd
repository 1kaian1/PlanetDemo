extends Node3D


@onready var UI3D = get_node("/root/main/UI3D")

@onready var main = get_node("/root/main")
@onready var planet_rotation = get_node("/root/main/UI3D/Node3D")
@onready var discover_button = get_node("/root/main/UI2D/Control/MarginContainer/GridContainer/DiscoverButton")
@onready var search_button = get_node("/root/main/UI2D/Control/MarginContainer/GridContainer/SearchButton")
@onready var home_button = get_node("/root/main/UI2D/Control/MarginContainer/GridContainer/HomeButton")
@onready var camera = get_node("/root/main/UI3D/Camera3D")
@onready var grid = get_node("/root/main/UI2D/Control/MarginContainer/GridContainer")
@onready var search_circle = get_node("/root/main/UI2D/Control/MarginContainer2")
@onready var coin_field = get_node("/root/main/UI3D/Node3D/CoinField")
@onready var red_circle = get_node("/root/main/UI2D/Control/MarginContainer2/TextureRect2")

var target_position : Vector3
var lerp_speed : float = 5.0  # Rychlost interpolace
var buttons_split := false



func _ready():
	discover_button.connect("pressed", Callable(self, "_on_DiscoverButton_pressed"))
	home_button.connect("pressed", Callable(self, "_on_HomeButton_pressed"))
	search_button.connect("pressed", Callable(self, "_on_SearchButton_pressed"))
	
	target_position = camera.position

	# Na začátku skryjeme menší tlačítka
	search_button.visible = false
	search_circle.visible = false	
	
	
func _on_SearchButton_pressed():
	var origin = Vector3(0, 0, 0)  # Počáteční bod (střed světa)

	# ✅ Převod kvaternionu na matici a získání směru pohledu
	var rotation = UI3D.rotation_quat
	var basis = Basis(rotation)
	var camera_direction = basis.z.normalized()  # Skutečný směr kamery v prostoru

	# ✅ Spočítáme bod na přímce pohledu kamery, vzdálený 500 jednotek od počátku
	var target_position = origin - camera_direction * 100 

	# ✅ Vytvoření 2D kolečka (`Sprite3D` pro umístění v 3D prostoru)
	var new_circle = Sprite3D.new()
	new_circle.texture = preload("res://textures/white_circle.png")  # Cesta k textuře
	new_circle.scale = Vector3(10,10,10)
	new_circle.position = target_position  # **Použití všech tří souřadnic X, Y, Z!**

	# ✅ Přidání kruhu do 3D scény
	UI3D.add_child(new_circle)

	print("✅ Kolečko vytvořeno na:", target_position)


	
	
func _on_HomeButton_pressed():	
	
	var current_position = camera.position
	var distance = current_position.length()
	
	if distance < 150:
		target_position = Vector3(0, 0, 200)
		planet_rotation.rotation_speed = 0.2
		UI3D.rotation_speed = 0.5



		
	else:
		target_position = Vector3(0, 0, 60)
		planet_rotation.rotation_speed = 0.0
		UI3D.rotation_speed = 0.02

	


func _on_DiscoverButton_pressed():	
	
	var current_position = camera.position
	var distance = current_position.length()

	if distance < 50:
		# Přiblížení
		target_position = Vector3(0, 0, 200)
		
		grid.columns = 2
		
		search_button.visible = false
		
		discover_button.text = "Discover"	
		
		search_circle.visible = false	
		
		coin_field.visible = true
		
		home_button.visible = true
		
	else:
		
		coin_field.visible = false
		
		search_button.visible = true
		
		search_circle.visible = true
		
		home_button.visible = false
		
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
