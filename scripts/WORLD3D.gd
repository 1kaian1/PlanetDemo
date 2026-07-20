## WORLD2D3D test merge

extends Node3D

var rotation_quat : Quaternion = Quaternion.IDENTITY
var target_rotation : Quaternion = Quaternion.IDENTITY
var dragging : bool = false
var last_touch_pos : Vector2 = Vector2.ZERO
var active_touches : int = 0

@export var rotation_speed : float = 0.1

# ---------------------------------------------------------------------------
# KAMERA JE OD _ready() STATICKÁ. Veškerý "pohyb kamery" se ve skutečnosti
# počítá na neviditelném pomocném uzlu `rig` a promítá se jako OPAČNÁ
# transformace na `map_root` (planetu). Vizuálně je výsledek identický
# s původním řešením, ale reálná Camera3D se nikdy nehne.
# ---------------------------------------------------------------------------

var camera: Camera3D            # reálná kamera – po _ready() se už nehýbe
var rig: Node3D                 # "virtuální kamera" – běží na ní stará logika
var base_cam_transform: Transform3D

var pivot := Vector3.ZERO
var offset := Vector3(0, 0, 148)  # PROHOZENO Y -> Z (relativní vektor rigu k pivotu)

var pan_speed := 0.1
var rotate_speed := 0.005
var zoom_speed := 0.075
var pitch_speed := 0.0005

var min_pitch := deg_to_rad(-85)
var max_pitch := deg_to_rad(-25)

var touches := {}
var last_dist := 0.0
var last_angle := 0.0
var last_pos := {}
var prev_pos := {}

const TILE_SIZE := 20.0
const MAP_SIZE := 20
#TILE_SIZE*MAP_SIZE = 400 ## TRIO

var map_root: Node3D

func _ready():
	if not camera:
		camera = $Camera3D

	map_root = Node3D.new()
	map_root.name = "MapRoot"
	add_child(map_root)

	rig = Node3D.new()
	rig.name = "OrbitRig"
	add_child(rig)

	_generate_wrapped_map(MAP_SIZE)

	pivot = Vector3(0, 0, 500) # PROHOZENO Y -> Z
	rig.global_position = pivot + offset
	rig.look_at(pivot, Vector3.FORWARD) # Změna UP vektoru na FORWARD (osa Z je teď "nahoru")
	offset = rig.global_position - pivot

	# Kamera se natrvalo "zaparkuje" na startovní pozici rigu a dál
	# se s ní už nikdy nehýbe ani netočí.
	camera.global_transform = rig.global_transform
	base_cam_transform = camera.global_transform


	_draw_bounds()
	_update_planet_transform()

func _input(event):

	# -------- TOUCH (mobil) --------
	if event is InputEventScreenTouch:
		if event.pressed:
			last_pos[event.index] = event.position
			touches[event.index] = event.position
			if touches.size() == 2:
				last_dist = 0.0
				last_angle = 0.0
		else:
			touches.erase(event.index)
			last_pos.erase(event.index)

		if event.pressed:
			active_touches += 1
		else:
			active_touches -= 1

		if active_touches > 1:
			return

		dragging = event.pressed
		last_touch_pos = event.position


	elif event is InputEventScreenDrag:
		var idx = event.index
		if last_pos.has(idx):
			prev_pos[idx] = last_pos[idx]
		last_pos[idx] = event.position
		touches[idx] = event.position

		if touches.size() == 1:
			var delta = last_pos[idx] - prev_pos.get(idx, last_pos[idx])
			_pan(delta)
		elif touches.size() == 2:
			_orbit_with_pitch()

	# -------- MOUSE (PC) --------
	elif event is InputEventMouseMotion:
		var delta: Vector2 = event.relative

		var left := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
		var right := Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)

		if left and right:
			_orbit_pitch(delta.y)

		elif left:
			_pan(delta)

	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_handle_mouse_zoom(-1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_handle_mouse_zoom(1)

	if event is InputEventScreenDrag and dragging:

		if active_touches == 1:

			var delta : Vector2 = event.position - last_touch_pos
			last_touch_pos = event.position

			var pitch : Quaternion = Quaternion(Vector3.RIGHT, delta.y * 0.01)
			var yaw : Quaternion = Quaternion(Vector3.UP, delta.x * 0.01)


			target_rotation = pitch * yaw * rotation_quat



func _handle_keyboard_pan():
	var move := Vector3.ZERO
	var right := rig.global_transform.basis.x
	right.z = 0 # PROHOZENO Y -> Z
	right = right.normalized()
	var forward := rig.global_transform.basis.y # PROHOZENO Z -> Y
	forward.z = 0 # PROHOZENO Y -> Z
	forward = forward.normalized()

	if Input.is_action_pressed("ui_up"):
		move -= forward * pan_speed * 10
	if Input.is_action_pressed("ui_down"):
		move += forward * pan_speed * 10
	if Input.is_action_pressed("ui_left"):
		move -= right * pan_speed * 10
	if Input.is_action_pressed("ui_right"):
		move += right * pan_speed * 10

	if move != Vector3.ZERO:
		pivot += move
		rig.global_position += move
		offset = rig.global_position - pivot

func _handle_keyboard_rotate(delta):
	var rot := 0.0

	if Input.is_action_pressed("ui_left"):
		rot += rotate_speed * 60 * delta
	if Input.is_action_pressed("ui_right"):
		rot -= rotate_speed * 60 * delta

	if rot != 0.0:
		_orbit_rotate(rot)

func _handle_mouse_zoom(direction: float):
	var dir := offset.normalized()
	var distance := offset.length()

	distance = clamp(
		distance + direction * zoom_speed * distance,
		10.0,
		150.0
	)

	offset = dir * distance
	rig.global_position = pivot + offset


# ---------------- Zoom ----------------
func _zoom(amount: float):
	var dir = offset.normalized()
	var dist = offset.length()
	dist = clamp(dist - amount * zoom_speed, 10.0, 150.0)
	offset = dir * dist
	rig.global_position = pivot + offset

# ---------------- Pan ----------------
func _pan(delta: Vector2):
	var right = rig.global_transform.basis.x
	right.z = 0 # PROHOZENO Y -> Z
	right = right.normalized()

	var forward = rig.global_transform.basis.y # PROHOZENO Z -> Y
	forward.z = 0 # PROHOZENO Y -> Z
	forward = forward.normalized()

	var move = (-delta.x * pan_speed) * right + (delta.y * pan_speed) * forward

	pivot += move
	rig.global_position += move
	offset = rig.global_position - pivot

# ---------------- Orbit & Pitch ----------------
func _orbit_with_pitch():
	var keys = touches.keys()
	var p0 = touches[keys[0]]
	var p1 = touches[keys[1]]

	# pinch zoom
	var dist = p0.distance_to(p1)
	if last_dist != 0.0:
		_zoom(dist - last_dist)
	last_dist = dist

	# yaw
	var angle = (p1 - p0).angle()
	if last_angle != 0.0:
		_orbit_rotate(angle - last_angle)
	last_angle = angle

	# pitch
	var idx0 = keys[0]
	var idx1 = keys[1]

	if not prev_pos.has(idx0) or not prev_pos.has(idx1):
		return

	var delta_y0 = last_pos[idx0].y - prev_pos[idx0].y
	var delta_y1 = last_pos[idx1].y - prev_pos[idx1].y
	var delta_x0 = last_pos[idx0].x - prev_pos[idx0].x
	var delta_x1 = last_pos[idx1].x - prev_pos[idx1].x

	# oba prsty stejným směrem nahoru/dolů
	if delta_y0 * delta_y1 > 0 and abs(delta_x0) < 20 and abs(delta_x1) < 20:
		_orbit_pitch((delta_y0 + delta_y1) * 0.5)


func _orbit_rotate(angle_delta: float):
	offset = offset.rotated(Vector3.FORWARD, angle_delta) # PROHOZENO UP -> FORWARD
	rig.global_position = pivot + offset
	rig.look_at(pivot, Vector3.FORWARD) # PROHOZENO UP -> FORWARD

func _orbit_pitch(delta_y: float):
	var radius = offset.length()
	var horizontal_offset = Vector3(offset.x, offset.y, 0) # PROHOZENO z na y
	var yaw = atan2(horizontal_offset.x, horizontal_offset.y) # PROHOZENO z na y
	var pitch = asin(offset.z / radius) # PROHOZENO y na z

	pitch += delta_y * pitch_speed
	var min_p = deg_to_rad(25)
	var max_p = deg_to_rad(90)
	pitch = clamp(pitch, min_p, max_p)

	offset.x = radius * cos(pitch) * sin(yaw)
	offset.y = radius * cos(pitch) * cos(yaw) # PROHOZENO z na y logiku
	offset.z = radius * sin(pitch) # PROHOZENO y na z logiku

	rig.global_position = pivot + offset
	rig.look_at(pivot, Vector3.FORWARD) # PROHOZENO UP -> FORWARD

func _process(delta):

	rotation_quat = rotation_quat.slerp(target_rotation, rotation_speed)
	
	var universal_rotation = rotation_quat.get_euler()
	
	$PlanetRotation.rotation = universal_rotation
	$StarField.rotation = universal_rotation
	$LootField.rotation = universal_rotation
	$DiscoveryField.rotation = universal_rotation
	$"XXX-Axis".rotation = universal_rotation
	$Shield.rotation = universal_rotation

	_handle_keyboard_pan()
	_handle_keyboard_rotate(delta)

	if not camera:
		return

	var pivot_pos = pivot

	if pivot_pos.x < -TILE_SIZE*MAP_SIZE/2:
		pivot_pos.x += TILE_SIZE*MAP_SIZE
	elif pivot_pos.x > TILE_SIZE*MAP_SIZE/2:
		pivot_pos.x -= TILE_SIZE*MAP_SIZE

	if pivot_pos.y < -TILE_SIZE*MAP_SIZE/2: # PROHOZENO z -> y
		pivot_pos.y += TILE_SIZE*MAP_SIZE
	elif pivot_pos.y > TILE_SIZE*MAP_SIZE/2: # PROHOZENO z -> y
		pivot_pos.y -= TILE_SIZE*MAP_SIZE

	# aplikace wrap posunu na pivot a rig (NE na skutečnou kameru)
	var delta2: Vector3 = pivot_pos - pivot
	pivot = pivot_pos
	rig.global_position += delta2

	_update_planet_transform()
	_update_curvature()


# ---------------- Tady se "prohazuje" kamera s planetou ----------------
func _update_planet_transform():
	# map_root dostane přesně opačnou transformaci, jakou by jinak dostala
	# kamera. Výsledný obraz je stejný jako v originále, ale
	# camera.global_transform se nikdy nemění.
	map_root.global_transform = base_cam_transform * rig.global_transform.affine_inverse()
	print(camera.position)


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

	var base_z := 400.0 ## TRIO - PROHOZENO base_y -> base_z

	for dx in range(-1, 2):
		for dy in range(-1, 2): # PROHOZENO dz -> dy
			for i in range(original_map.size()):
				var tile_type: int = original_map[i]
				var tile := _create_tile(tile_type)

				var x := i % width
				@warning_ignore("integer_division")
				var y := int(i / width) # PROHOZENO z -> y

				var world_x := -(TILE_SIZE*width)/2 + dx*TILE_SIZE*width + x*TILE_SIZE + TILE_SIZE/2
				var world_y := -(TILE_SIZE*width)/2 + dy*TILE_SIZE*width + y*TILE_SIZE + TILE_SIZE/2 # PROHOZENO z -> y

				tile.position = Vector3(world_x, world_y, base_z) # PROHOZENO Y a Z argumenty
				map_root.add_child(tile)

# ---------------- Dynamické zaoblení ----------------
func _update_curvature():
	var radius := 400.0 ## TRIO
	var cam_xy := Vector2(camera.global_position.x, camera.global_position.y) # PROHOZENO z -> y
	var sphere_center := Vector3(camera.global_position.x, camera.global_position.y, 0) # PROHOZENO z a y místa

	for tile_parent in map_root.get_children():
		if not tile_parent is Node3D:
			continue

		var plane := tile_parent.get_node_or_null("Plane")
		if plane == null:
			continue

		# ---------- výška ----------
		var tile_xy := Vector2(plane.global_position.x, plane.global_position.y) # PROHOZENO z -> y
		var dist := tile_xy.distance_to(cam_xy)

		if dist < TILE_SIZE * 0.5:
			plane.position.z = 0.0 # PROHOZENO y -> z
		elif dist < radius:
			plane.position.z = -(radius - sqrt(radius * radius - dist * dist)) # PROHOZENO y -> z
		else:
			plane.position.z = -radius # PROHOZENO y -> z

		# ---------- normála ----------
		var world_pos := Vector3(plane.global_position)
		var normal := (world_pos - sphere_center).normalized()

		var tangent := normal.cross(Vector3.UP) # Změna směru kvůli přehození os (FORWARD -> UP)
		if tangent.length() < 0.001:
			tangent = normal.cross(Vector3.RIGHT)

		tangent = tangent.normalized()
		var bitangent := tangent.cross(normal)

		var basis := Basis(
			tangent,
			normal, # PROHOZENO normal a bitangent pořadí pro zachování ortonormality při swapu os
			bitangent
		)

		plane.global_transform.basis = basis

		# ---------- HOTEL ----------
		var hotel := tile_parent.get_node_or_null("Hotel")
		if hotel:
			hotel.global_transform.basis = basis
			hotel.scale = Vector3(0.7, 0.7, 0.7)
			hotel.position.z = plane.position.z + 0.1 # PROHOZENO y -> z

func _create_tile(tile_type: int) -> Node3D:
	var tile_parent := Node3D.new()

	var tile := MeshInstance3D.new()
	tile.name = "Plane"
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(TILE_SIZE, TILE_SIZE)
	# PlaneMesh se standardně generuje v rovině XZ. Chcete-li, aby nativně ležel v XY, 
	# můžete mu v editoru změnit orientaci, ale skript ho níže stejně přerotuje pomocí basis.
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

	tile.material_override = mat
	tile_parent.add_child(tile)

	if tile_type == 2:
		var hotel_scene := preload("res://textures/hotel/Hotel(3star).fbx")
		var hotel_instance: Node3D = hotel_scene.instantiate()
		hotel_instance.name = "Hotel"
		hotel_instance.scale = Vector3(0.5, 0.5, 0.5)
		tile_parent.add_child(hotel_instance)

	return tile_parent



func _draw_bounds():
	var line_height := 5.0
	var thickness := 1.0

	var base_z := 400.0 + line_height # PROHOZENO base_y -> base_z
	var half_size := MAP_SIZE * TILE_SIZE * 0.5

	var min_pos := -half_size
	var max_pos :=  half_size

	# 2 linie podél X
	map_root.add_child(create_line(
		Vector3(min_pos, min_pos, base_z), # PROHOZENO Y a Z souřadnice
		Vector3(max_pos, min_pos, base_z),
		thickness
	))  # přední

	map_root.add_child(create_line(
		Vector3(min_pos, max_pos, base_z), # PROHOZENO Y a Z souřadnice
		Vector3(max_pos, max_pos, base_z),
		thickness
	))  # zadní

	# 2 linie podél Y (původně Z)
	map_root.add_child(create_line(
		Vector3(min_pos, min_pos, base_z), # PROHOZENO Y a Z souřadnice
		Vector3(min_pos, max_pos, base_z),
		thickness
	))  # levá

	map_root.add_child(create_line(
		Vector3(max_pos, min_pos, base_z), # PROHOZENO Y a Z souřadnice
		Vector3(max_pos, max_pos, base_z),
		thickness
	))  # pravá

func create_line(start: Vector3, end: Vector3, thickness: float = 0.2) -> MeshInstance3D:
	var dir := end - start
	var mid := (start + end) * 0.5

	var mesh := BoxMesh.new()

	var size_x: float = abs(dir.x)
	var size_y: float = abs(dir.y) # PROHOZENO z -> y

	mesh.size = Vector3(
		max(size_x, 0.01),
		max(size_y, 0.01), # PROHOZENO tloušťka a rozměr
		thickness
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
