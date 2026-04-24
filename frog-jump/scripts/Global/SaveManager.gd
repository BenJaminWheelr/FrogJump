extends Node

signal data_modified

const SAVE_PATH = "user://savegame.json"

const DEFAULT_DATA = {
	"player": {
		"highest_level_unlocked": 1,
		"coins": 0,
	},
	"settings": {
		"audioEnabled": true,
	},
	"shop": {
		"owned_items": [],
		"equipped_item": "",
	},
	"speedrunRecords": {
		# level_id: [float, float, float]
	}
}

var data = {}

func _ready():
	load_game()
	_ensure_defaults()

func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()
	data_modified.emit()
	
		
func update_data(section: String, key: String, value):
	if data.has(section) and data[section].has(key):
		data[section][key] = value
		save_game()
	else:
		push_error("SaveManager: Attempted to update non-existent key: " + section + "/" + key)
		
func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		data = DEFAULT_DATA.duplicate(true)
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json = JSON.new()
		if json.parse(file.get_as_text()) == OK:
			data = json.data
		file.close()

func reset_save_data():
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	
	data = DEFAULT_DATA.duplicate(true)
	save_game()
	

func update_speedrun_record(level_id: String, raw_time: float) -> void:
	# Initialize level entry if missing
	if not data["speedrunRecords"].has(level_id):
		data["speedrunRecords"][level_id] = []

	var new_entry = {
		"raw": raw_time,
		"formatted": TimeKeeper.format_time(raw_time)
	}

	var scores = data["speedrunRecords"][level_id]
	scores.append(new_entry)
	
	scores.sort_custom(TimeKeeper.sort_records)
	
	# Keep only top 3
	if scores.size() > 3:
		scores.resize(3)
	
	data["speedrunRecords"][level_id] = scores
	save_game()

func get_speedrun_records(level_id: String) -> Array:
	return data["speedrunRecords"].get(level_id, [])

func _ensure_defaults() -> void:
	var defaults = DEFAULT_DATA.duplicate(true)
	for section in defaults.keys():
		if not data.has(section):
			data[section] = defaults[section]
		else:
			for key in defaults[section].keys():
				if not data[section].has(key):
					data[section][key] = defaults[section][key]
