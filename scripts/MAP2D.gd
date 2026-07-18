extends Node2D

# ---------------- MAP ----------------
var zoom = 14
var center_tile = Vector2i(4823, 6160)
var tile_size = 256

# dynamicky podle displeje
var tiles_x
var tiles_y

# ---------------- DISPLAY ----------------
var screen_width = 2400
var screen_height = 1080
var screen_offset = Vector2(screen_width/2, screen_height/2)

# ---------------- NODES ----------------
var tile_container : Node2D
var tile_sprites = {}   # cache tiles

# ---------------- DRAG ----------------
var dragging = false
var last_touch_pos = Vector2.ZERO
var map_offset = Vector2.ZERO

# ---------------- ZOOM LIMITS ----------------
const MIN_ZOOM = 3
const MAX_ZOOM = 19

# ---------------- SMOOTH ZOOM ----------------
var zoom_float : float = zoom
var zoom_scale : float = 1.0


# =========================================================
# READY
# =========================================================
func _ready():
	# kolik tiles je potřeba pro celý display (+2 buffer)
	tiles_x = int(ceil(screen_width / tile_size)) + 2
	tiles_y = int(ceil(screen_height / tile_size)) + 2

	tile_container = Node2D.new()
	add_child(tile_container)

	update_visible_tiles()


# =========================================================
# TILE MANAGEMENT (HLAVNÍ LOGIKA)
# =========================================================
func update_visible_tiles():
	var needed_tiles := {}
	var half_x = tiles_x / 2
	var half_y = tiles_y / 2

	# --- tiles které MUSÍ existovat ---
	for i in range(-int(half_x), int(half_x)+1):
		for j in range(-int(half_y), int(half_y)+1):
			var coords = Vector2i(center_tile.x+i, center_tile.y+j)
			needed_tiles[coords] = true
			if not tile_sprites.has(coords):
				load_tile(coords)

	# --- smažeme tiles mimo obraz ---
	for coords in tile_sprites.keys():
		if not needed_tiles.has(coords):
			tile_sprites[coords].queue_free()
			tile_sprites.erase(coords)


# =========================================================
# LOAD TILE
# =========================================================
func load_tile(tile_coords: Vector2i):
	var url = "https://a.basemaps.cartocdn.com/light_all/%d/%d/%d.png" % [
		zoom, tile_coords.x, tile_coords.y
	]

	var http = HTTPRequest.new()
	add_child(http)

	http.request_completed.connect(
		_on_tile_loaded.bind(tile_coords)
	)
	http.request(url)


func _on_tile_loaded(result, code, headers, body, tile_coords):
	if code != 200:
		return

	# tile už mohl být mezitím smazán
	if tile_sprites.has(tile_coords):
		return

	var img = Image.new()
	img.load_png_from_buffer(body)
	var tex = ImageTexture.create_from_image(img)

	var sprite = Sprite2D.new()
	sprite.texture = tex
	tile_container.add_child(sprite)

	tile_sprites[tile_coords] = sprite

	update_tile_positions()
	

func reload_all_tiles():
	for sprite in tile_sprites.values():
		sprite.queue_free()
	tile_sprites.clear()
	update_visible_tiles()


# =========================================================
# UPDATE POSITIONS (BEZ RELOADU!)
# =========================================================
func update_tile_positions():
	for coords in tile_sprites.keys():
		var sprite = tile_sprites[coords]
		var dx = (coords.x - center_tile.x) * tile_size
		var dy = (coords.y - center_tile.y) * tile_size
		sprite.position = Vector2(dx, dy) + screen_offset + map_offset


# =========================================================
# TOUCH + SMOOTH MOUSE ZOOM
# =========================================================
func _input(event):
	if event is InputEventScreenTouch:
		dragging = event.pressed
		last_touch_pos = event.position

	elif event is InputEventScreenDrag and dragging:
		var delta = event.position - last_touch_pos
		last_touch_pos = event.position
		map_offset += delta
		update_tile_positions()
		check_tile_shift()
	
	elif event is InputEventMouseButton and event.pressed:
		# smooth fractional zoom
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_float += 0.1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_float -= 0.1

		zoom_float = clamp(zoom_float, MIN_ZOOM, MAX_ZOOM)
		update_smooth_zoom(event.position)


# =========================================================
# TILE SHIFT
# =========================================================
func check_tile_shift():
	var shift_x = 0
	var shift_y = 0
	if abs(map_offset.x) >= tile_size:
		shift_x = int(map_offset.x / tile_size)
	if abs(map_offset.y) >= tile_size:
		shift_y = int(map_offset.y / tile_size)

	if shift_x == 0 and shift_y == 0:
		return

	center_tile -= Vector2i(shift_x, shift_y)
	map_offset -= Vector2(shift_x, shift_y) * tile_size

	update_visible_tiles()
	update_tile_positions()


# =========================================================
# SMOOTH ZOOM IMPLEMENTACE
# =========================================================
func update_smooth_zoom(mouse_pos:Vector2):
	var base_zoom = floor(zoom_float)
	var fractional = zoom_float - base_zoom

	# vizuální scale mezi zoom levely
	zoom_scale = pow(2.0, fractional)
	tile_container.scale = Vector2.ONE * zoom_scale

	check_zoom_threshold(mouse_pos)


func check_zoom_threshold(mouse_pos:Vector2):
	var target_zoom = int(floor(zoom_float))
	if target_zoom == zoom:
		return

	# faktor změny tiles
	var factor = pow(2, target_zoom - zoom)

	# pozice kurzoru v mapových tile coordinates
	var world_mouse = mouse_pos - screen_offset - tile_container.position
	var tile_offset = world_mouse / tile_size
	var mouse_tile = Vector2(center_tile) + tile_offset
	mouse_tile *= factor

	# přepočet nového středu
	center_tile = Vector2i(
		int(mouse_tile.x - tile_offset.x),
		int(mouse_tile.y - tile_offset.y)
	)

	# reset offset a scale
	map_offset = Vector2.ZERO
	tile_container.position = Vector2.ZERO
	tile_container.scale = Vector2.ONE
	zoom_scale = 1.0

	# načtení nových tiles pro nový zoom level
	zoom = target_zoom
	reload_all_tiles()
