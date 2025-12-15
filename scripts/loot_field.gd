extends Node3D

@onready var camera: Camera3D = get_node("/root/main/Camera3D")
@onready var discovery_field: Node3D = get_node("/root/main/UI3D/DiscoveryField")
@onready var star_field: Node3D = get_node("/root/main/UI3D/StarField")

func _process(_delta):
	randomize()

	for area in discovery_field.get_children():
		if area is Area3D:
			for sprite in area.get_children():
				if sprite is Sprite3D and sprite.has_meta("type") and sprite.get_meta("type") == "empty":
					
					# pokud už vykřičníky existují, přeskoč
					if sprite.has_meta("exclamation_created") and sprite.get_meta("exclamation_created"):
						continue
					
					var count = randi() % 5 + 1
					
					for i in range(count):
						var coin_sprite = Sprite3D.new()
						coin_sprite.texture = load("res://textures/exclamation_mark.png")
						coin_sprite.scale = Vector3(1,1,1)
						coin_sprite.layers = 1
						
						# přidej přímo pod discovery_field
						add_child(coin_sprite)
						
						# globální pozice poblíž původního sprite
						coin_sprite.global_position = sprite.global_position + Vector3(
							randf_range(-50, 50),
							randf_range(-50, 50),
							randf_range(-50, 50))
							
							
						coin_sprite.look_at(Vector3.ZERO, Vector3.UP)
						
						
						
						
					# označ sprite, že vykřičníky byly vytvořeny
					sprite.set_meta("exclamation_created", true)
						





func has_coin_at_position(pos: Vector3, tolerance: float = 0.1) -> bool:
	for child in star_field.get_children():
		if child is Area3D:
			if child.global_position.distance_to(pos) < tolerance:
				return true
	return false
