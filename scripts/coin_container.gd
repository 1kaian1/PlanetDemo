extends Node3D

const COIN_COUNT = 20
const PLANET_RADIUS = 50.0

func _ready():
	# ✅ Vytvoření coinů uvnitř `CoinContainer`
	for i in range(COIN_COUNT):
		var pos = get_random_position_on_surface(PLANET_RADIUS)

		# 🟡 Vytvoření coinu
		var coin = MeshInstance3D.new()
		coin.mesh = SphereMesh.new()
		coin.position = pos
		coin.name = "coin_" + str(i)
		coin.scale = Vector3(5, 5, 5)
		add_child(coin)

		# ✅ Unikátní materiál pro každý coin
		var material = StandardMaterial3D.new()
		material.albedo_color = Color(1, 1, 0)
		coin.set_surface_override_material(0, material)

		# ✅ Interaktivní oblast
		var coin_area = Area3D.new()
		coin_area.position = pos
		coin_area.name = "coin_area_" + str(i)
		add_child(coin_area)

		# ✅ Kolizní tvar
		var collision_shape = CollisionShape3D.new()
		var shape = SphereShape3D.new()
		shape.radius = 10
		collision_shape.shape = shape
		coin_area.add_child(collision_shape)

		coin_area.collision_layer = 1
		coin_area.collision_mask = 1

		if not coin_area.input_event.is_connected(_on_coin_clicked.bind(coin, coin_area)): 
			coin_area.input_event.connect(_on_coin_clicked.bind(coin, coin_area))

# ✅ Detekce kliknutí na coin s fade-out efektem
func _on_coin_clicked(coin, coin_area, camera, event, position, normal, shape_idx):
	print("🖱️ Kliknutí zachyceno na: " + coin.name)

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("✅ Coin " + coin.name + " mizí...")

		var material = coin.get_surface_override_material(0)
		if material:
			var fade_duration = 0.5
			var steps = 10
			var delay = fade_duration / steps

			for i in range(steps):
				await get_tree().create_timer(delay).timeout
				material.albedo_color.a = max(0, material.albedo_color.a - (1.0 / steps))

		coin.queue_free()
		coin_area.queue_free()

# ✅ Správná pozice na povrchu koule
func get_random_position_on_surface(radius: float) -> Vector3:
	var theta = randf_range(0, PI * 2)
	var phi = randf_range(0, PI)
	var x = radius * sin(phi) * cos(theta)
	var y = radius * sin(phi) * sin(theta)
	var z = radius * cos(phi)
	return Vector3(x, y, z).normalized() * radius
