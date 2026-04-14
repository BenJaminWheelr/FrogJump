class_name LevelContainer extends Node2D

const LEVEL_DIR = "res://scenes/level/"
const NO_LEVEL_FALLBACK = "res://scenes/level/0.tscn"

static var currLevelIndex : int = 0;
const PLAYER_START_POS : Vector2 = Vector2i(512, 480);
var currLevel : Level = null;

func _ready():
	resetLevel();

static func getLevelPath(index : int) -> String:
	var newLevelPath = LEVEL_DIR + str(index) + ".tscn"
	if FileAccess.file_exists(newLevelPath):
		return newLevelPath
	return NO_LEVEL_FALLBACK;

func loadLevel(index : int):
	currLevelIndex = index;
	if currLevel != null:
		currLevel.queue_free();
	currLevel = load(getLevelPath(index)).instantiate();
	currLevel.connect("level_complete", Callable(self, "nextLevel"));
	
	if (currLevel.bg_img1 != null):
		$"LevelBackground/1/BackgroundImage".texture = currLevel.bg_img1;
	if (currLevel.bg_img2 != null):
		$"LevelBackground/2/BackgroundImage".texture = currLevel.bg_img2;
	if (currLevel.bg_img3 != null):
		$"LevelBackground/3/BackgroundImage".texture = currLevel.bg_img3;
	
	$LevelParent.call_deferred("add_child", currLevel);
	$Player.position = PLAYER_START_POS;
	$Player/Camera2D.reset_smoothing();

func resetLevel():
	loadLevel(currLevelIndex);

func nextLevel():
	currLevelIndex += 1
	loadLevel(currLevelIndex);

static func setLevelIndex(index : int):
	currLevelIndex = index;
