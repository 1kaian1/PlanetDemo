extends MeshInstance3D

var rotation_speed = 0.0 # 0.2  # Rychlost otáčení (v radiánech za sekundu)

func _process(delta):
	# Rotace kolem osy y
	rotate_y(rotation_speed * delta)
	
