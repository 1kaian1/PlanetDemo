extends Node3D

@export var WINDOW_FIELD_RADIUS = 300

@onready var coin_field = get_node("/root/main/PlanetRotation/CoinField")
@onready var planet_rotation = get_node("/root/main/PlanetRotation")
@onready var planet_earth = get_node("/root/main/PlanetRotation/PlanetEarth")
@onready var main = get_node("/root/main")
@onready var camera = get_node("/root/main/Camera3D")
@onready var ui = get_node("/root/main/DiscoveryUI")

func _ready():
	ui.search_pressed.connect(_on_SearchButton_pressed)
	ui.set_home_ui(true)
	visible = false
		
func _process(delta):
	
	if camera.position.z < 75:
		coin_field.visible = false
		planet_rotation.rotation_speed = 0.0
		#main.rotation_speed = 0.02
	else:
		coin_field.visible = true
		planet_rotation.rotation_speed = 0.2
		#main.rotation_speed = 0.1
		
	if camera.position.z < 55:
		planet_earth.fade_out()
	else:
		planet_earth.fade_in()
		
	if camera.position.z < 20:
		visible = true
		ui.set_discovery_ui(true)
	else:
		visible = false
		ui.set_home_ui(true)
	
func _on_SearchButton_pressed():
	ui.save_coins(-100)
	
	var pos = get_position_in_camera_view()
	var lookup_area = Area3D.new()
	lookup_area.position = pos
	add_child(lookup_area)
	lookup_area.look_at(Vector3.ZERO, Vector3.UP)

	var circle_full_sprite = Sprite3D.new()
	circle_full_sprite.texture = load("res://textures/red_circle_full.png")
	circle_full_sprite.scale = Vector3.ZERO
	circle_full_sprite.layers = 2
	circle_full_sprite.set_meta("type", "full")
	lookup_area.add_child(circle_full_sprite)
	
	var circle_empty_dotted_sprite = Sprite3D.new()
	circle_empty_dotted_sprite.texture = load("res://textures/red_circle_empty_dotted.png")
	circle_empty_dotted_sprite.scale = Vector3(28,28,28)
	circle_empty_dotted_sprite.layers = 2
	circle_empty_dotted_sprite.set_meta("type", "empty")
	lookup_area.add_child(circle_empty_dotted_sprite)
	
	var countdown_label = Label3D.new()
	countdown_label.text = "00:40"
	countdown_label.font_size = 2048
	countdown_label.modulate = Color.WHITE
	countdown_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	lookup_area.add_child(countdown_label)
	
	var tween = create_tween()
	tween.tween_property(circle_full_sprite, "scale", Vector3(13.5,13.5,13.5), 40) \
		 .set_trans(Tween.TRANS_LINEAR) \
		 .set_ease(Tween.EASE_IN_OUT)
	
	var total_seconds = 40
	var countdown_time = total_seconds
	var countdown_timer = Timer.new()
	countdown_timer.wait_time = 1
	countdown_timer.one_shot = false
	countdown_timer.autostart = true
	lookup_area.add_child(countdown_timer)
	
	lookup_area.set_meta("countdown_time", 40)
	countdown_timer.timeout.connect(func():
		var ct = lookup_area.get_meta("countdown_time")
		ct -= 1
		lookup_area.set_meta("countdown_time", ct)
		
		var minutes = ct / 60
		var seconds = ct % 60
		countdown_label.text = "%02d:%02d" % [minutes, seconds]

		if ct <= 0:
			countdown_timer.stop()
			countdown_label.queue_free()
	)


	
func get_position_in_camera_view():
	
	var rotation = main.rotation_quat
	var world_direction = (rotation.inverse() * Vector3(0, 0, -1)).normalized()

	var position_on_sphere = world_direction * WINDOW_FIELD_RADIUS
	return position_on_sphere
