extends SubViewport

@onready var label: Label = $CanvasLayer/Label

func _ready():
	await get_tree().process_frame
	var main_vp_size = get_tree().root.get_visible_rect().size
	size = main_vp_size
	print("SubViewport set to:", size)
