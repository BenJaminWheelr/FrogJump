class_name Level extends Node2D

const LEVEL_DIR = "res://scenes/level/"
const NO_LEVEL_FALLBACK = "res://scenes/UI/MainMenu.tscn"
static var currLevel : int = 0;

static func getLevelPath(index : int) -> String:
	var newLevelPath = LEVEL_DIR + str(index) + ".tscn"
	if FileAccess.file_exists(newLevelPath):
		return newLevelPath
	return NO_LEVEL_FALLBACK
	
func nextLevel():
	currLevel += 1
	get_tree().call_deferred("change_scene_to_file", getLevelPath(currLevel))
