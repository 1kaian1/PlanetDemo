extends Node3D

var camera: Camera3D
var pivot := Vector3.ZERO
var offset := Vector3(0,148,0)  # relativní vektor kamery k pivotu

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

	_generate_wrapped_map(MAP_SIZE)

	pivot = Vector3(0, 500, 0)
	camera.global_position = pivot + offset
	camera.look_at(pivot, Vector3.UP)
	offset = camera.global_position - pivot

	_draw_bounds()
	
	
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




func _handle_keyboard_pan():
	var move := Vector3.ZERO
	var right := camera.global_transform.basis.x
	right.y = 0
	right = right.normalized()
	var forward := camera.global_transform.basis.z
	forward.y = 0
	forward = forward.normalized()

	if Input.is_action_pressed("ui_up"):    # šipka nahoru / W
		move -= forward * pan_speed * 10  # násobíme, aby byla rychlejší
	if Input.is_action_pressed("ui_down"):  # šipka dolů / S
		move += forward * pan_speed * 10
	if Input.is_action_pressed("ui_left"):  # šipka doleva / A
		move -= right * pan_speed * 10
	if Input.is_action_pressed("ui_right"): # šipka doprava / D
		move += right * pan_speed * 10

	if move != Vector3.ZERO:
		pivot += move
		camera.global_position += move
		offset = camera.global_position - pivot

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
	camera.global_position = pivot + offset

	
# ---------------- Zoom ----------------
func _zoom(amount: float):
	var dir = offset.normalized()
	var dist = offset.length()
	dist = clamp(dist - amount * zoom_speed, 10.0, 150.0)
	offset = dir * dist
	camera.global_position = pivot + offset

# ---------------- Pan ----------------
func _pan(delta: Vector2):
	var right = camera.global_transform.basis.x
	right.y = 0
	right = right.normalized()

	var forward = camera.global_transform.basis.z
	forward.y = 0
	forward = forward.normalized()

	var move = (-delta.x * pan_speed) * right + (-delta.y * pan_speed) * forward

	pivot += move
	camera.global_position += move
	offset = camera.global_position - pivot

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
	offset = offset.rotated(Vector3.UP, angle_delta)
	camera.global_position = pivot + offset
	camera.look_at(pivot, Vector3.UP)

func _orbit_pitch(delta_y: float):
	var radius = offset.length()
	var horizontal_offset = Vector3(offset.x, 0, offset.z)
	var yaw = atan2(horizontal_offset.x, horizontal_offset.z)
	var pitch = asin(offset.y / radius)

	pitch += delta_y * pitch_speed
	var min_p = deg_to_rad(25)
	var max_p = deg_to_rad(90)
	pitch = clamp(pitch, min_p, max_p)

	offset.x = radius * cos(pitch) * sin(yaw)
	#offset.y = radius * sfin(pitch)
	offset.z = radius * cos(pitch) * cos(yaw)

	camera.global_position = pivot + offset
	camera.look_at(pivot, Vector3.UP)

func _process(delta):
	
	_handle_keyboard_pan()
	_handle_keyboard_rotate(delta)

	if not camera:
		return

	var pivot_pos = pivot

	if pivot_pos.x < -TILE_SIZE*MAP_SIZE/2:
		pivot_pos.x += TILE_SIZE*MAP_SIZE
	elif pivot_pos.x > TILE_SIZE*MAP_SIZE/2:
		pivot_pos.x -= TILE_SIZE*MAP_SIZE

	if pivot_pos.z < -TILE_SIZE*MAP_SIZE/2:
		pivot_pos.z += TILE_SIZE*MAP_SIZE
	elif pivot_pos.z > TILE_SIZE*MAP_SIZE/2:
		pivot_pos.z -= TILE_SIZE*MAP_SIZE

	# aplikace posunu na pivot a kameru
	var delta2: Vector3 = pivot_pos - pivot
	pivot = pivot_pos
	camera.global_position += delta2

	_update_curvature()
	
	
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
	
	var base_y := 400.0 ## TRIO

	for dx in range(-1, 2):
		for dz in range(-1, 2):
			for i in range(original_map.size()):
				var tile_type: int = original_map[i]
				var tile := _create_tile(tile_type)

				var x := i % width
				@warning_ignore("integer_division")
				var z := int(i / width)
				
				var world_x := -(TILE_SIZE*width)/2 + dx*TILE_SIZE*width + x*TILE_SIZE + TILE_SIZE/2
				var world_z := -(TILE_SIZE*width)/2 + dz*TILE_SIZE*width + z*TILE_SIZE + TILE_SIZE/2

				tile.position = Vector3(world_x, base_y, world_z)
				add_child(tile)

# ---------------- Dynamické zaoblení ----------------
func _update_curvature():
	var radius := 400.0 ## TRIO
	var cam_xz := Vector2(camera.global_position.x, camera.global_position.z)
	var sphere_center := Vector3(camera.global_position.x,0,camera.global_position.z)

	for tile_parent in get_children():
		if not tile_parent is Node3D:
			continue

		var plane := tile_parent.get_node_or_null("Plane")
		if plane == null:
			continue

		# ---------- výška ----------
		var tile_xz := Vector2(plane.global_position.x, plane.global_position.z)
		var dist := tile_xz.distance_to(cam_xz)

		if dist < TILE_SIZE * 0.5:
			plane.position.y = 0.0
		elif dist < radius:
			plane.position.y = -(radius - sqrt(radius * radius - dist * dist))
		else:
			plane.position.y = -radius

		# ---------- normála ----------
		var world_pos := Vector3(plane.global_position)
		var normal := (world_pos - sphere_center).normalized()

		var tangent := normal.cross(Vector3.FORWARD)
		if tangent.length() < 0.001:
			tangent = normal.cross(Vector3.RIGHT)

		tangent = tangent.normalized()
		var bitangent := tangent.cross(normal)

		var basis := Basis(
			tangent,
			normal,
			bitangent
		)

		plane.global_transform.basis = basis

		# ---------- HOTEL ----------
		var hotel := tile_parent.get_node_or_null("Hotel")
		if hotel:
			hotel.global_transform.basis = basis
			hotel.scale = Vector3(0.7, 0.7, 0.7)
			hotel.position.y = plane.position.y + 0.1

func _create_tile(tile_type: int) -> Node3D:
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

	var base_y := 400.0 + line_height
	var half_size := MAP_SIZE * TILE_SIZE * 0.5

	var min_pos := -half_size
	var max_pos :=  half_size

	# 2 linie podél X
	add_child(create_line(
		Vector3(min_pos, base_y, min_pos),
		Vector3(max_pos, base_y, min_pos),
		thickness
	))  # přední

	add_child(create_line(
		Vector3(min_pos, base_y, max_pos),
		Vector3(max_pos, base_y, max_pos),
		thickness
	))  # zadní

	# 2 linie podél Z
	add_child(create_line(
		Vector3(min_pos, base_y, min_pos),
		Vector3(min_pos, base_y, max_pos),
		thickness
	))  # levá

	add_child(create_line(
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
	line.global_position = mid

	return line
