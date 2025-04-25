extends Node2D

var tile_size = 256
var zoom = 10
var center_tile_x = 540
var center_tile_y = 345
var offset = Vector2.ZERO  # jemný posun
var velocity = Vector2.ZERO  # rychlost pro plynulé posouvání
var friction = 0.95  # tření pro zpomalení pohybu (0.95 = pomalé zpomalení, 0.98 = rychlé zpomalení)
var drag_sensitivity = 0.5  # citlivost pro drag (nižší = pomalejší pohyb)

var api_key = "IEaWHMt1rEr501Lu3hNS"  # Tohle je tvůj Mapbox API klíč
var base_url = "https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/{z}/{x}/{y}?access_token="

var screen_width = 1080
var screen_height = 2400

var is_dragging = false
var drag_start = Vector2.ZERO
var drag_map_start = Vector2.ZERO

var tile_cache = {}  # nový cache slovník

func _ready():
	redraw_map()

func redraw_map():
	# Smaž pouze staré sprity (dlaždice), ne HTTPRequest ani cache
	for child in get_children():
		if child is Sprite2D:
			child.queue_free()

	var tiles_x = ceil(float(screen_width) / tile_size) + 2
	var tiles_y = ceil(float(screen_height) / tile_size) + 2

	for dx in range(-tiles_x / 2, tiles_x / 2):
		for dy in range(-tiles_y / 2, tiles_y / 2):
			var x = center_tile_x + dx
			var y = center_tile_y + dy
			var cache_key = "%d_%d_%d" % [zoom, x, y]

			var screen_center = Vector2(screen_width / 2, screen_height / 2)
			var position = screen_center + offset + Vector2(dx * tile_size, dy * tile_size)

			if tile_cache.has(cache_key):
				# použij z cache
				var sprite = Sprite2D.new()
				sprite.texture = tile_cache[cache_key]
				sprite.position = position
				add_child(sprite)
			else:
				var url = "%s%d/%d/%d.png?access_token=%s" % [base_url, zoom, x, y, api_key]
				var http_request = HTTPRequest.new()
				add_child(http_request)
				http_request.request_completed.connect(_on_request_completed.bind(http_request, dx, dy, zoom, x, y))
				http_request.request(url)

func _on_request_completed(result, response_code, headers, body, http_request, dx, dy, z, x, y):
	if result != HTTPRequest.RESULT_SUCCESS:
		http_request.queue_free()
		return

	var image = Image.new()
	if image.load_png_from_buffer(body) != OK:
		http_request.queue_free()
		return

	var texture = ImageTexture.create_from_image(image)

	var cache_key = "%d_%d_%d" % [z, x, y]
	tile_cache[cache_key] = texture  # ulož do cache

	var sprite = Sprite2D.new()
	sprite.texture = texture

	var screen_center = Vector2(screen_width / 2, screen_height / 2)
	sprite.position = screen_center + offset + Vector2((x - center_tile_x) * tile_size, (y - center_tile_y) * tile_size)
	add_child(sprite)

	http_request.queue_free()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = event.pressed
			if is_dragging:
				drag_start = event.position
				drag_map_start = offset

		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if zoom < 18:
				zoom += 1
				center_tile_x *= 2
				center_tile_y *= 2
				offset *= 2
				redraw_map()

		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if zoom > 0:
				zoom -= 1
				center_tile_x /= 2
				center_tile_y /= 2
				offset /= 2
				redraw_map()

	elif event is InputEventMouseMotion and is_dragging:
		# Plynulejší posouvání pomocí zpomalení a setrvačnosti
		velocity = (event.position - drag_start) * drag_sensitivity
		offset = drag_map_start + velocity

		# Zajištění správného posouvání po dlaždicích
		while offset.x > tile_size:
			offset.x -= tile_size
			center_tile_x -= 1
		while offset.x < -tile_size:
			offset.x += tile_size
			center_tile_x += 1

		while offset.y > tile_size:
			offset.y -= tile_size
			center_tile_y -= 1
		while offset.y < -tile_size:
			offset.y += tile_size
			center_tile_y += 1

		redraw_map()

	elif event is InputEventMouseMotion and not is_dragging:
		# Po ukončení tažení zpomalí plynule na základě tření
		velocity *= friction
		offset += velocity
		if velocity.length() < 1:  # Pokud je rychlost velmi malá, zastav
			velocity = Vector2.ZERO
		redraw_map()
