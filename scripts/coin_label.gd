extends Label

@export var save_path = "user://save_file.json"

func save_coins():
	
	var coins_gathered = load_coins()
	coins_gathered += 1
	
	var save_data = {"coins": coins_gathered}
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()
	
	#text = str(coins_gathered)
	
func load_coins():	
		
	if FileAccess.file_exists("user://save_file.json"):
		
		var file = FileAccess.open("user://save_file.json", FileAccess.READ)
		var save_data = JSON.parse_string(file.get_as_text())
		file.close()
		
		if save_data:
			text = str(int(save_data.get("coins", 0) + 1))
			return save_data.get("coins", 0)
	
	text = "0"
	return 0
