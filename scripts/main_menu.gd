extends Control

@onready var viewport := $SubViewport
var scene3d = preload("res://scenes/main.tscn")

func _ready():
	var instance = scene3d.instantiate()
	viewport.add_child(instance)
	
	# Najdi kameru uvnitř instancované scény
	var cam = instance.get_node("main/")  # uprav cestu podle hierarchie scény
	if cam:
		viewport.camera = cam  # KLÍČOVÉ: přiřadíme ji přímo k SubViewportu
	else:
		print("Camera not found in preloadované scéně!")
