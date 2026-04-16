extends Node

const SAVE_PATH = "user://savegame.json"

var data = {
	"player": {
		"highest_level_unlocked": 1
	},
	"settings": {
		"audioEnabled": true
	}
}

func _ready():
	load_game()

func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(data)
		file.store_string(json_string)
		file.close()
		
func update_data(section: String, key: String, value):
	if data.has(section) and data[section].has(key):
		data[section][key] = value
		save_game()

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(json_string)
		if error == OK:
			data = json.data
