extends Node3D

@export var STAR_FIELD_RADIUS = 300
@export var STAR_COUNT = 500

func _ready():
		
	for i in range(STAR_COUNT):
		
		var pos = get_random_position_on_surface()
		var coin_node = Area3D.new()
		coin_node.position = pos
		coin_node.set_meta("is_collected", false)
		add_child(coin_node)

		var coin_sprite = Sprite3D.new()
		coin_sprite.texture = load("res://textures/white_circle.png")
		coin_sprite.scale = Vector3(1,1,1)
		coin_node.look_at(Vector3.ZERO, Vector3.UP)
		coin_node.add_child(coin_sprite)

func get_random_position_on_surface():
	
	var theta = randf_range(0, PI * 2)
	var phi = randf_range(0, PI)
	var x = STAR_FIELD_RADIUS * sin(phi) * cos(theta)
	var y = STAR_FIELD_RADIUS * sin(phi) * sin(theta)
	var z = STAR_FIELD_RADIUS * cos(phi)
	
	return Vector3(x, y, z).normalized() * STAR_FIELD_RADIUS
