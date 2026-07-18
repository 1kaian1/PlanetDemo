extends Node3D

@onready var camera: Camera3D = get_node("/root/WORLD3D/Camera3D")
@onready var discovery_field: Node3D = get_node("/root/WORLD3D/DiscoveryField")

var selected_sprite: Sprite3D = null
var selected_label: Label3D = null
var brackets_sprite: Sprite3D = null
var touch_start_pos: Vector2
var touched_sprite: Sprite3D = null
var is_dragging := false

func _process(_delta):
	randomize()

	for lookup_area in discovery_field.get_children():
		if lookup_area is Area3D:
			for sprite in lookup_area.get_children():
				if sprite is Sprite3D and sprite.has_meta("type") and sprite.get_meta("type") == "empty":
					
					if sprite.has_meta("exclamation_created") and sprite.get_meta("exclamation_created"):
						continue
					
					var count = randi() % 5 + 1
					
					for i in range(count):
						var exclamation_sprite = Sprite3D.new()
						exclamation_sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
						exclamation_sprite.texture = load("res://textures/exclamation_mark.png")
						exclamation_sprite.scale = Vector3(5,5,5)
						exclamation_sprite.layers = 1
						exclamation_sprite.visible = false
						
						add_child(exclamation_sprite)
						
						exclamation_sprite.global_position = 4.9 * (sprite.global_position + Vector3(
							randf_range(-50, 50),
							randf_range(-50, 50),
							0))
							
						exclamation_sprite.look_at(Vector3.ZERO, Vector3.UP)
						
						var area_click = Area3D.new()
						exclamation_sprite.add_child(area_click)

						var shape = CollisionShape3D.new()
						var sphere = SphereShape3D.new()
						sphere.radius = 10.0
						shape.shape = sphere
						area_click.add_child(shape)

						exclamation_sprite.set_meta("id", exclamation_sprite.get_instance_id())
						exclamation_sprite.set_meta("visible", false)
						
					sprite.set_meta("exclamation_created", true)
					
				if sprite is Sprite3D and sprite.has_meta("type") and sprite.get_meta("type") == "full":
					
					for exclamation in get_children():
						if exclamation is Sprite3D and exclamation.has_meta("visible") and !exclamation.get_meta("visible"):
							
							var sprite_center = sprite.global_position
							var exclamation_center = exclamation.global_position.normalized() * 300.0
							var dist = exclamation_center.distance_to(sprite_center)
							
							var aabb = sprite.get_aabb()
							var scale = sprite.global_transform.basis.get_scale()
							var radius = aabb.size.x * 0.5 * scale.x
						
							if radius >= dist:
								exclamation.visible = true
								
func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			is_dragging = false
			touch_start_pos = event.position
			touched_sprite = _raycast_exclamation(event.position)

		else:
			_handle_touch_release(event.position)

	elif event is InputEventScreenDrag:
		is_dragging = true

func _handle_touch_release(screen_pos: Vector2):
	if is_dragging:
		return

	if touched_sprite == null:
		_clear_selection()
		return

	if touched_sprite != selected_sprite:
		_select_sprite(touched_sprite)

func _handle_touch_start(screen_pos: Vector2):
	var hit_sprite = _raycast_exclamation(screen_pos)

	if hit_sprite == null:
		_clear_selection()
		return

	if hit_sprite != selected_sprite:
		_select_sprite(hit_sprite)

func _raycast_exclamation(screen_pos: Vector2) -> Sprite3D:
	var from = camera.project_ray_origin(screen_pos)
	var to = from + camera.project_ray_normal(screen_pos) * 10000

	var query = PhysicsRayQueryParameters3D.new()
	query.from = from
	query.to = to
	query.collision_mask = 1
	query.collide_with_areas = true

	var result = get_world_3d().direct_space_state.intersect_ray(query)

	if result and result.collider:
		var sprite = result.collider.get_parent()
		if sprite is Sprite3D and sprite.has_meta("id"):
			return sprite

	return null

func _select_sprite(sprite: Sprite3D):
	_clear_selection()

	selected_sprite = sprite

	brackets_sprite = Sprite3D.new()
	brackets_sprite.texture = load("res://textures/brackets.png")
	brackets_sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	brackets_sprite.scale = Vector3(2, 2, 2)
	brackets_sprite.position = Vector3(0, 0, -0.1)
	selected_sprite.add_child(brackets_sprite)

	selected_label = Label3D.new()
	selected_label.text = str(sprite.get_meta("id"))
	selected_label.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	selected_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	selected_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	selected_label.font_size = 1024
	selected_label.modulate = Color.WHITE
	selected_label.position = Vector3(0, -15, 0)

	selected_sprite.add_child(selected_label)

	selected_sprite.set_meta("label", selected_label)

func _clear_selection():
	if brackets_sprite and is_instance_valid(brackets_sprite):
		brackets_sprite.queue_free()
	
	if selected_label and is_instance_valid(selected_label):
		selected_label.queue_free()

	brackets_sprite = null
	selected_sprite = null
	selected_label = null
