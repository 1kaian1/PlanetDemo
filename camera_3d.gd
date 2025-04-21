extends Camera3D

# Zpracování kliknutí
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Získání kamery a její pozice na obrazovce
		var camera = get_viewport().get_camera_3d()
		if camera:
			var from = camera.project_ray_origin(event.position)  # Počáteční bod ray
			var to = from + camera.project_ray_normal(event.position) * 1000  # Konec ray (dohled 1000 jednotek)

			# Vytvoření raycastu
			var ray_params = PhysicsRayQueryParameters3D.create(from, to)
			var space_state = get_world_3d().direct_space_state  # Přístup k fyzikálnímu světu
			var result = space_state.intersect_ray(ray_params)

			if result and result.collider:
				print("Kliknuto na: ", result.collider.name)
				# Pokud jsi kliknul na objekt s názvem "coin_", tak ho smaž
				if result.collider.name.begins_with("coin_"):
					result.collider.queue_free()  # Odstraní kliknutý coin
