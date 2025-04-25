extends Button

func _ready():
	connect("pressed", Callable(self, "_on_Button_pressed"))
	
func _on_Button_pressed():
	var new_scene = load("res://scenes/factories.tscn")
	if new_scene == null:
		print("Scéna nebyla načtena!")
		return
	print("Scéna byla načtena!")
	get_tree().change_scene_to_file("res://scenes/factories.tscn")
