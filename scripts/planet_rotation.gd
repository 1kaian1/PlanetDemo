extends Node3D

@export var rotation_speed := 0.2

func _process(delta):
	$PlanetEarth.rotate_y(rotation_speed * delta)
	$CoinField.rotate_y(rotation_speed * delta)
	#$Explosion.rotate_y(rotation_speed * delta)
