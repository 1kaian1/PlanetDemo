extends Camera3D

@export var subviewport_camera: Camera3D  # přiřadíš v Inspectoru

func _ready():
	cull_mask = 1  # vidí jen kolečka

func _process(_delta):
	if subviewport_camera:
		subviewport_camera.transform = transform
