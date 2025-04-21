extends Node3D

const COIN_MAX_COUNT = 25
const COINS_PER_MINUTE = 5
const COIN_FIELD_RADIUS = 50.2
const COIN_COLLISION_FIELD = 100
const CLICK_DELAY = 1

@onready var camera = get_node("/root/main/UI3D/Camera3D")
@onready var save_game = get_node("/root/main/Node")
@onready var spawn_timer = Timer.new()

var coins_currently_spawned = 0
var coins_gathered = 0


func _ready():
		
	coins_gathered = save_game.load_coins()
	$/root/main/UI2D/Control/CoinBar/Label.text = str(int(coins_gathered))
	
	spawn_timer.wait_time = 6.0 / COINS_PER_MINUTE

	add_child(spawn_timer)
	spawn_timer.connect("timeout", Callable(self, "_spawn_coin"))
	spawn_timer.start()

func _spawn_coin():
	
	if coins_currently_spawned < COIN_MAX_COUNT:
		create_coin()
		coins_currently_spawned += 1
				
func _input(event):
	
	if event is InputEventMouseButton and event.pressed:
				
		for i in range(get_child_count()):
			
			var coin_node = get_child(i)
			
			if coin_node is Area3D:
				
				var coin_screen_pos = camera.unproject_position(coin_node.global_transform.origin)
				var distance = event.position.distance_to(coin_screen_pos) 
				
				if distance <= COIN_COLLISION_FIELD:
					_on_coin_clicked(coin_node)

func _on_coin_clicked(coin_node):
	
	if coin_node.get_meta("is_collected"):
		return
	else:
		coin_node.set_meta("is_collected", true)
	
	var coin_sprite = coin_node.get_child(0)
	
	var fade_duration = 0.5
	var steps = 10
	var delay = fade_duration / steps

	for i in range(steps):
			
		await get_tree().create_timer(delay).timeout
		coin_sprite.modulate.a = max(0, coin_sprite.modulate.a - (1.0 / steps))

	coin_node.queue_free()
	
	coins_currently_spawned -= 1
	coins_gathered += 1
	save_game.save_coins(coins_gathered)
	
	$/root/main/UI2D/Control/CoinBar/Label.text = str(int(coins_gathered))

func get_random_position_on_surface():
	
	var theta = randf_range(0, PI * 2)
	var phi = randf_range(0, PI)
	var x = COIN_FIELD_RADIUS * sin(phi) * cos(theta)
	var y = COIN_FIELD_RADIUS * sin(phi) * sin(theta)
	var z = COIN_FIELD_RADIUS * cos(phi)
	
	return Vector3(x, y, z).normalized() * COIN_FIELD_RADIUS

func create_coin():
	
		var pos = get_random_position_on_surface()
		var coin_node = Area3D.new()
		coin_node.position = pos
		coin_node.set_meta("is_collected", false)
		add_child(coin_node)

		var coin_sprite = Sprite3D.new()
		coin_sprite.texture = load("res://textures/coin.png")
		coin_sprite.scale = Vector3(2,2,2)
		coin_node.look_at(Vector3.ZERO, Vector3.UP)
		coin_node.add_child(coin_sprite)
		
		_on_coin_spawned(coin_node)
		
func _on_coin_spawned(coin_node):
	
	var coin_sprite = coin_node.get_child(0)
	
	coin_sprite.modulate.a = 0

	var fade_duration = 0.5
	var steps = 10
	var delay = fade_duration / steps

	for i in range(steps):
		await get_tree().create_timer(delay).timeout
		coin_sprite.modulate.a = min(1.0, coin_sprite.modulate.a + (1.0 / steps))
