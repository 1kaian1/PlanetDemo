extends ScrollContainer

var last_touch_pos = null

func _ready():
	for i in 10:
		var block = Panel.new()
		block.custom_minimum_size = Vector2(300, 300)
		block.add_theme_color_override("panel", Color.RED)
		
		var label = Label.new()
		label.text = "Blok %d" % (i + 1)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		block.add_child(label)
		block.mouse_filter = Control.MOUSE_FILTER_PASS  # ⬅️ důležité!
		$HBoxContainer.add_child(block)
		
		# Přidáme klikací chování
		block.connect("gui_input", Callable(self, "_on_block_input").bind(i))

	# Aktivuj zachytávání vstupu
	set_process_input(true)
	set_process_unhandled_input(true)
	
func _on_block_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Kliknuto na blok č. ", index + 1)


func _unhandled_input(event):
	# Dotyk začal
	if event is InputEventScreenTouch:
		if event.pressed:
			last_touch_pos = event.position
		else:
			last_touch_pos = null

	# Tažení prstem / touchpadem
	elif event is InputEventScreenDrag and last_touch_pos != null:
		scroll_horizontal -= event.relative.x  # Posun horizontálně
