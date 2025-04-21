extends Node3D

@export var rotation_speed := 0.2 # radiány za sekundu

var planet: MeshInstance3D
var coinfield: Node3D



func _ready():
	planet = get_node("EarthPlanet")
	coinfield = get_node("CoinField")
	if planet == null:
		print("⚠️ Planeta nebyla nalezena!")

func _process(delta):
	if planet:
		planet.rotate_y(rotation_speed * delta)
	if coinfield:
		coinfield.rotate_y(rotation_speed * delta)
