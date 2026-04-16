class_name LevelContainer extends Node2D

const LEVEL_DIR = "res://scenes/level/"
const NO_LEVEL_FALLBACK = "res://scenes/level/0.tscn"

static var currLevelIndex : int = 0;
const PLAYER_START_POS : Vector2 = Vector2i(512, 480);
const PLAYER_OFFSCREEN_POS : Vector2 = Vector2i(512, 4800);
var currLevel : Level = null;

@export var levelHUD : CanvasLayer

func _ready():
	resetLevel();

static func getLevelPath(index : int) -> String:
	var newLevelPath = LEVEL_DIR + str(index) + ".tscn"
	if FileAccess.file_exists(newLevelPath):
		return newLevelPath
	return NO_LEVEL_FALLBACK;
	
func initiateHUD(currentLevel : Level):
	var goal_node = currentLevel.get_node_or_null("goal")
	
	if goal_node and levelHUD:
		levelHUD.finish_line = goal_node
		levelHUD.setup()
	else:
		print("Warning: Either missing goal-node/levelHUD reference")
	

func loadLevel(index : int):
	currLevelIndex = index;
	if currLevel != null:
		currLevel.queue_free();
	currLevel = load(getLevelPath(index)).instantiate();
	initiateHUD(currLevel)
	currLevel.connect("level_clear_anim_started", Callable(self, "levelClearAnimationStarted"))
	currLevel.connect("level_complete", Callable(self, "nextLevel"));
	
	$Player.position = PLAYER_OFFSCREEN_POS if currLevel is Cutscene else PLAYER_START_POS;
	$Player.has_key = false;
	$Player.control_mode = $Player.ControlMode.WAIT_FOR_INPUT_BEFORE_AUTO_RUNNER;
	$Player/Camera2D.reset_smoothing();
	
	if (currLevel.bg_img1 != null):
		$"LevelBackground/1/BackgroundImage".texture = currLevel.bg_img1;
	if (currLevel.bg_img2 != null):
		$"LevelBackground/2/BackgroundImage".texture = currLevel.bg_img2;
	if (currLevel.bg_img3 != null):
		$"LevelBackground/3/BackgroundImage".texture = currLevel.bg_img3;
	
	$LevelParent.call_deferred("add_child", currLevel);

func resetLevel():
	loadLevel(currLevelIndex);

func nextLevel():
	SaveManager.update_data("player", "highest_level_unlocked", currLevelIndex+2)
	currLevelIndex += 1
	loadLevel(currLevelIndex);

func levelClearAnimationStarted():
	print("Level cleared!")
	# TODO: show message, show how many coins were collected out of the total

static func setLevelIndex(index : int):
	currLevelIndex = index;
