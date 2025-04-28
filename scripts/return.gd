extends Button

func _ready():
	# Připojení signálu pomocí Callable
	connect("pressed", Callable(self, "_on_Button_pressed"))

func _on_Button_pressed():
	# Změna scény
	get_tree().change_scene_to_file("res://scenes/main.tscn")
