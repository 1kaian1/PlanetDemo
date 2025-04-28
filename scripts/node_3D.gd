extends Node2D

var tile_size = 256  # Velikost dlaždice pro běžné mapy (256x256)
var zoom = 12  # Standardní úroveň zoomu pro podrobnější zobrazení (Google Maps styl)
var center_tile_x = 540
var center_tile_y = 345
var offset = Vector2.ZERO  # jemný posun
var velocity = Vector2.ZERO  # rychlost pro plynulé posouvání
var friction = 0.95  # tření pro zpomalení pohybu
var drag_sensitivity = 0.3  # citlivost pro drag

var api_key = "ItmOkg30ZmpjFygaNDGR"  # Tohle je tvůj Maplibre API klíč
var base_url = "https://a.tile.openstreetmap.org/%d/%d/%d.png"

var screen_width = 1080
var screen_height = 2400

var is_dragging = false
var drag_start = Vector2.ZERO
var drag_map_start = Vector2.ZERO

var tile_cache = {}  # nový cache slovník

# Uložení pozic prstů pro zoomování
var touch_points = []

# Přidání proměnné pro uchování předchozí vzdálenosti mezi prsty
var prev_distance = -1  # Počáteční hodnota je neplatná

func _ready():
	redraw_map()

func redraw_map():
	# Smaž pouze staré sprity (dlaždice), ne HTTPRequest ani cache
	for child in get_children():
		if child is Sprite2D:
			child.queue_free()

	# Počet dlaždic na šířku a výšku obrazovky
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
				var url = base_url % [zoom, x, y]
				var http_request = HTTPRequest.new()
				add_child(http_request)
				http_request.request_completed.connect(_on_request_completed.bind(http_request, dx, dy, zoom, x, y))
				http_request.request(url)

func _on_request_completed(result, response_code, headers, body, http_request, dx, dy, z, x, y):
	if result != HTTPRequest.RESULT_SUCCESS:
		print("Request failed with code %d" % response_code)  # Debug: ověření chyby
		http_request.queue_free()
		return

	var image = Image.new()
	if image.load_png_from_buffer(body) != OK:
		print("Failed to load image")  # Debug: ověření načítání obrázku
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

# Funkce pro detekci dotykového vstupu
func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			# Přidání nového prstu do seznamu
			touch_points.append(event.position)
		else:
			# Odstranění uvolněného prstu ze seznamu
			touch_points.erase(event.position)

		if len(touch_points) == 2:
			# Pokud jsou dva prsty na displeji, provádíme zoom
			var touch1 = touch_points[0]
			var touch2 = touch_points[1]

			# Vypočítáme vzdálenost mezi prsty
			var dist = touch1.distance_to(touch2)

			# Pokud se vzdálenost změnila, provádíme zoom
			if prev_distance == -1:  # Pokud je hodnota -1, znamená to, že předchozí vzdálenost ještě není nastavena
				prev_distance = dist
			else:
				var zoom_factor = dist / prev_distance

				# Změna zoomu na základě zoom_factor
				if zoom_factor > 1 and zoom < 18:  # Přílišný zoom nahoru
					zoom += 1
				elif zoom_factor < 1 and zoom > 0:  # Přílišný zoom dolů
					zoom -= 1

				prev_distance = dist  # Uložení nové vzdálenosti pro další iteraci

			# Na základě nového zoomu posuneme mapu podle prstů
			var center_map_x = (touch1.x + touch2.x) / 2
			var center_map_y = (touch1.y + touch2.y) / 2

			# Převedení pozic prstů na nové souřadnice mapy
			var offset_diff_x = (center_map_x - screen_width / 2) / tile_size
			var offset_diff_y = (center_map_y - screen_height / 2) / tile_size

			center_tile_x -= offset_diff_x
			center_tile_y -= offset_diff_y

			redraw_map()

	elif event is InputEventScreenDrag:
		# Pohyb mapy při dragování
		offset += event.relative * drag_sensitivity
		redraw_map()
