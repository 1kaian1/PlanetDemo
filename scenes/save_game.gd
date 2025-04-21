extends Node

var save_path = "user://save_file.json"

func save_coins(coins_gathered):
	var save_data = {"coins": coins_gathered}  # ✅ Vytvoření JSON objektu
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))  # ✅ Uložení jako JSON
	file.close()
	
func load_coins():	
	if FileAccess.file_exists("user://save_file.json"):  # ✅ Kontrola existence souboru
		var file = FileAccess.open("user://save_file.json", FileAccess.READ)
		var save_data = JSON.parse_string(file.get_as_text())  # ✅ Načtení a převod na JSON objekt
		file.close()		
		if save_data:
			return save_data.get("coins", 0)  # ✅ Načte počet mincí (nebo 0 jako výchozí hodnotu)
	return 0  # ✅ Pokud soubor není, vrátí 0
