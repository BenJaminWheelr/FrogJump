extends Node

const SAVE_PATH = "user://savegame.json"

var data = {
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
    }
}

func _ready():
    load_game()
    _ensure_defaults()


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


func _ensure_defaults() -> void:
    if not data.has("player"):
        data["player"] = {"highest_level_unlocked": 1, "coins": 0}
    if not data["player"].has("highest_level_unlocked"):
        data["player"]["highest_level_unlocked"] = 1
    if not data["player"].has("coins"):
        data["player"]["coins"] = 0

    if not data.has("settings"):
        data["settings"] = {"audioEnabled": true}
    if not data["settings"].has("audioEnabled"):
        data["settings"]["audioEnabled"] = true

    if not data.has("shop"):
        data["shop"] = {}
    if not data["shop"].has("owned_items"):
        data["shop"]["owned_items"] = []
    if not data["shop"].has("equipped_item"):
        data["shop"]["equipped_item"] = ""


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
            print("Successfully loaded player data")
            print(data)
