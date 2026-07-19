extends Node3D

# ---------------------------------------------------------------------------
# Sloučení dvou systémů:
#  1) Trackball rotace planety přes kvaterniony (drag prstem/myší)
#  2) Generování "zabalené" dlaždicové mapy + jejího falešného zakřivení
#     (planet_camera_swap.gd)
#
# Kamera se v tomhle systému NEHÝBE mimo zoom (ten řeší samostatný skript
# na Camera3D, viz position.z). Místo orbitu kamery kolem planety se otáčí
# přímo planeta (map_root) a případně i další vizuální vrstvy
# (StarField, LootField, DiscoveryField, XXX-Axis, Shield, PlanetRotation),
# pokud v dané scéně existují.
# ---------------------------------------------------------------------------

var camera: Camera3D

const TILE_SIZE := 20.0
const MAP_SIZE := 20
#TILE_SIZE*MAP_SIZE = 400 ## TRIO

var map_root: Node3D

# ---------------- Rotace planety (kvaterniony) ----------------
var rotation_quat: Quaternion = Quaternion.IDENTITY
var target_rotation: Quaternion = Quaternion.IDENTITY

@export var rotation_speed: float = 0.1      # slerp smoothing
@export var drag_sensitivity: float = 0.01   # citlivost tažení -> radiány

var dragging: bool = false
var last_touch_pos: Vector2 = Vector2.ZERO
var active_touches: int = 0

# Další vrstvy planety, které se mají otáčet spolu s mapou.
# Pokud v dané scéně některá z nich neexistuje, prostě se přeskočí
# (get_node_or_null místo $Node, aby to nespadlo jako sub_viewport.gd).
var extra_layers: Array[Node3D] = []


func _ready():
	if not camera:
		camera = $Camera3D

	map_root = Node3D.new()
	map_root.name = "MapRoot"
	add_child(map_root)

	extra_layers = _collect_extra_layers()

	_generate_wrapped_map(MAP_SIZE)
	_draw_bounds()

	# Kopule je zapečená vůči ose Y (vrchol míří nahoru), ale kamera se dívá
	# podél osy Z (stojí na (0,0,200) a kouká na počátek). Proto map_root
	# jednou napevno natočíme o 90° kolem X, aby vrchol "planety" mířil
	# přímo ke kameře. Dál se map_root už NIKDY neotáčí (viz _process) –
	# terén tak zůstává vizuálně statický vůči kameře, ať drag dělá cokoliv.
	map_root.rotation = Vector3(deg_to_rad(90), 0, 0)


func _collect_extra_layers() -> Array[Node3D]:
	var names := ["PlanetRotation", "StarField", "LootField", "DiscoveryField", "XXX-Axis", "Shield"]
	var found: Array[Node3D] = []
	for n in names:
		var node := get_node_or_null(n)
		if node and node is Node3D:
			found.append(node)
	return found


# ---------------------------------------------------------------------------
# INPUT – trackball rotace (touch i myš)
# ---------------------------------------------------------------------------
func _input(event):

	# -------- TOUCH (mobil) --------
	if event is InputEventScreenTouch:
		if event.pressed:
			active_touches += 1
		else:
			active_touches -= 1

		if active_touches > 1:
			return

		dragging = event.pressed
		last_touch_pos = event.position

	elif event is InputEventScreenDrag and dragging and active_touches == 1:
		var delta: Vector2 = event.position - last_touch_pos
		last_touch_pos = event.position
		_apply_drag_rotation(delta)

	# -------- MOUSE (PC) --------
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			last_touch_pos = event.position

	elif event is InputEventMouseMotion and dragging:
		_apply_drag_rotation(event.relative)


func _apply_drag_rotation(delta: Vector2):
	var pitch := Quaternion(Vector3.RIGHT, delta.y * drag_sensitivity)
	var yaw := Quaternion(Vector3.UP, delta.x * drag_sensitivity)
	target_rotation = pitch * yaw * rotation_quat


func _process(_delta):
	rotation_quat = rotation_quat.slerp(target_rotation, rotation_speed)
	var universal_rotation := rotation_quat.get_euler()

	# map_root (terén/planina) se záměrně NEOTÁČÍ – zůstává staticky
	# natočený vůči kameře. Otáčí se jen "vesmír" kolem něj.
	for layer in extra_layers:
		layer.rotation = universal_rotation


# ---------------- Generování mapy (beze změny oproti swap verzi) ----------------
func _generate_wrapped_map(width: int):

	var original_map: Array[int] = [
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	]

	var base_y := 0.0    # výška roviny dlaždic – shoduje se s pozicí kamery (y=0)
	var radius := 400.0  # poloměr "planety" pro zakřivení

	for dx in range(-1, 2):
		for dz in range(-1, 2):
			for i in range(original_map.size()):
				var tile_type: int = original_map[i]

				var x := i % width
				@warning_ignore("integer_division")
				var z := int(i / width)

				var world_x := -(TILE_SIZE*width)/2 + dx*TILE_SIZE*width + x*TILE_SIZE + TILE_SIZE/2
				var world_z := -(TILE_SIZE*width)/2 + dz*TILE_SIZE*width + z*TILE_SIZE + TILE_SIZE/2

				var tile := _create_tile(tile_type, world_x, world_z, base_y, radius)
				map_root.add_child(tile)


func _create_tile(tile_type: int, world_x: float, world_z: float, base_y: float, radius: float) -> Node3D:
	var tile_parent := Node3D.new()

	var tile := MeshInstance3D.new()
	tile.name = "Plane"
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(TILE_SIZE, TILE_SIZE)
	tile.mesh = mesh

	var mat := StandardMaterial3D.new()

	if tile_type == 0:
		mat.albedo_texture = load("res://textures/grass.png")
	elif tile_type == 1:
		mat.albedo_texture = load("res://textures/brackets.png")
	elif tile_type == 2:
		mat.albedo_texture = load("res://textures/grass.png")

	mat.emission_enabled = true
	mat.emission_texture = mat.albedo_texture
	mat.emission_energy = 1.0
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED  # jistota, dlaždice vidět z obou stran

	tile.material_override = mat
	tile_parent.add_child(tile)

	if tile_type == 2:
		var hotel_scene := preload("res://textures/hotel/Hotel(3star).fbx")
		var hotel_instance: Node3D = hotel_scene.instantiate()
		hotel_instance.name = "Hotel"
		hotel_instance.scale = Vector3(0.5, 0.5, 0.5)
		tile_parent.add_child(hotel_instance)

	# -----------------------------------------------------------------
	# Zakřivení se teď počítá JEDNOU, tady, natvrdo vůči (0,0,0) –
	# ne za běhu vůči pozici kamery. Tím pádem vrchol "kopule" i střed
	# rotace (lokální počátek map_root) jsou přesně ve stejném bodě.
	# -----------------------------------------------------------------
	var dist := Vector2(world_x, world_z).length()
	var sag := 0.0
	if dist < TILE_SIZE * 0.5:
		sag = 0.0
	elif dist < radius:
		sag = -(radius - sqrt(radius * radius - dist * dist))
	else:
		sag = -radius

	tile_parent.position = Vector3(world_x, base_y, world_z)
	tile.position.y = sag

	var sphere_center := Vector3(0, base_y - radius, 0)
	var world_pos := tile_parent.position + Vector3(0, sag, 0)
	var normal := (world_pos - sphere_center).normalized()

	var tangent := normal.cross(Vector3.FORWARD)
	if tangent.length() < 0.001:
		tangent = normal.cross(Vector3.RIGHT)
	tangent = tangent.normalized()
	var bitangent := tangent.cross(normal)

	var basis := Basis(tangent, normal, bitangent)
	tile.transform.basis = basis

	if tile_type == 2:
		var hotel2 := tile_parent.get_node_or_null("Hotel")
		if hotel2:
			hotel2.transform.basis = basis
			hotel2.scale = Vector3(0.7, 0.7, 0.7)
			hotel2.position.y = sag + 0.1

	return tile_parent


func _draw_bounds():
	var line_height := 5.0
	var thickness := 1.0

	var base_y := 0.0 + line_height
	var half_size := MAP_SIZE * TILE_SIZE * 0.5

	var min_pos := -half_size
	var max_pos :=  half_size

	map_root.add_child(create_line(
		Vector3(min_pos, base_y, min_pos),
		Vector3(max_pos, base_y, min_pos),
		thickness
	))  # přední

	map_root.add_child(create_line(
		Vector3(min_pos, base_y, max_pos),
		Vector3(max_pos, base_y, max_pos),
		thickness
	))  # zadní

	map_root.add_child(create_line(
		Vector3(min_pos, base_y, min_pos),
		Vector3(min_pos, base_y, max_pos),
		thickness
	))  # levá

	map_root.add_child(create_line(
		Vector3(max_pos, base_y, min_pos),
		Vector3(max_pos, base_y, max_pos),
		thickness
	))  # pravá

func create_line(start: Vector3, end: Vector3, thickness: float = 0.2) -> MeshInstance3D:
	var dir := end - start
	var mid := (start + end) * 0.5

	var mesh := BoxMesh.new()

	var size_x: float = abs(dir.x)
	var size_z: float = abs(dir.z)

	mesh.size = Vector3(
		max(size_x, 0.01),
		thickness,
		max(size_z, 0.01)
	)

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1, 1, 1)
	mat.emission_enabled = true
	mat.emission = Color(1, 1, 1)
	mat.emission_energy = 5.0

	var line := MeshInstance3D.new()
	line.mesh = mesh
	line.material_override = mat
	line.position = mid

	return line
