extends Control

@onready var labels := $CenterContainer/VBoxContainer.get_children()

func _ready():
	play_intro()

func play_intro():
	var tween = create_tween()

	# 1️⃣ skryj všechna slova
	for label in labels:
		label.visible = false

	# 2️⃣ postupně je zobraz
	for label in labels:
		tween.tween_callback(func():
			label.visible = true
		)
		tween.tween_interval(0.4) # pauza mezi slovy

	# 3️⃣ krátká pauza po zobrazení
	tween.tween_interval(1.0)

	# 4️⃣ rychle schovej všechna slova
	tween.tween_callback(func():
		for label in labels:
			label.visible = false
	)

	# 5️⃣ krátká pauza
	tween.tween_interval(0.3)

	# 6️⃣ znovu od začátku
	tween.tween_callback(func():
		play_intro()
	)
