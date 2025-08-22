extends Node3D

@export var rotation_speed := 0.2
@onready var planet = get_node("PlanetEarth")
@onready var coinfield = get_node("CoinField")
#@onready var explosion = get_node("Explosion")

func _process(delta):
	planet.rotate_y(rotation_speed * delta)
	coinfield.rotate_y(rotation_speed * delta)
	#explosion.rotate_y(rotation_speed * delta)
