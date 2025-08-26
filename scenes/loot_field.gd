extends Node3D

@onready var camera: Camera3D = get_node("/root/main/Camera3D")
@onready var discovery_field: Node3D = get_node("/root/main/SubViewport/DiscoveryField")
@onready var star_field: Node3D = get_node("/root/main/UI3D/StarField")

func _process(_delta):
	var circles = discovery_field.get_children()
	var stars = star_field.get_children()

	for circle in circles:
		# střed kolečka
		var center_3d = circle.global_transform.origin
		var center_2d = camera.unproject_position(center_3d)

		# okraj kolečka (vezmeme bod o 1 jednotku v lokálních souřadnicích a převedeme ho do globálních)
		#var edge_3d = circle.to_global(Vector3(1, 0, 0))
		#var edge_2d = camera.unproject_position(edge_3d)
		#var radius = center_2d.distance_to(edge_2d)
		
		var radius = 75
		

		# teď všechny hvězdy proti tomuto kolečku
		for star in stars:
			var star_pos_3d = star.global_transform.origin
			var star_pos_2d = camera.unproject_position(star_pos_3d)

			# test – hvězda uvnitř kolečka?
			var dist = star_pos_2d.distance_to(center_2d)
			if dist <= radius and not has_coin_at_position(star_pos_3d, 0.1):
				
				var dir = star_pos_3d.normalized()
				var new_pos = dir * 100.0
				
				var pos = new_pos
				var coin_node = Area3D.new()
				#if coin_node.is_inside_tree():
				coin_node.global_position = pos
				discovery_field.add_child(coin_node)
				
				var coin_sprite = Sprite3D.new()
				coin_sprite.texture = load("res://textures/exclamation_mark.png")
				coin_sprite.scale = Vector3(1,1,1)
				coin_sprite.layers = 2
				coin_node.look_at(Vector3.ZERO, Vector3.UP)
				coin_node.add_child(coin_sprite)

func has_coin_at_position(pos: Vector3, tolerance: float = 0.1) -> bool:
	for child in star_field.get_children():
		if child is Area3D:
			if child.global_position.distance_to(pos) < tolerance:
				return true
	return false
