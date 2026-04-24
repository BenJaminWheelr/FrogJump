class_name LevelContainer extends Node2D

const LEVEL_DIR = "res://scenes/level/"
const GAME_END_PATH = "res://scenes/level/GameEnd.tscn"

static var currLevelIndex : int = 0;
const PLAYER_START_POS : Vector2 = Vector2i(512, 516);
const PLAYER_OFFSCREEN_POS : Vector2 = Vector2i(512, 4800);
var currLevel : Level = null;

@export var levelHUD : CanvasLayer

var speedrunTimer : TimeKeeper = TimeKeeper.new()

func _ready():
	resetLevel();
	$Player.auto_runner_started.connect(speedrunTimer.start)
	currLevel.level_clear_anim_started.connect(onLevelComplete)
	
func onLevelComplete() -> void:
	speedrunTimer.stop()
	var elapsedTime = speedrunTimer.get_elapsed()
	SaveManager.update_speedrun_record(str(currLevelIndex), elapsedTime)
	

static func getLevelPath(index : int) -> String:
	var newLevelPath = LEVEL_DIR + str(index) + ".tscn"
	if ResourceLoader.exists(newLevelPath, "PackedScene"):
		return newLevelPath
	return "";
	
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
		
	var newLevelPath = getLevelPath(index);
	if (newLevelPath == ""):
		# switch to game end cutscene
		get_tree().change_scene_to_file(GAME_END_PATH);
		return;
	
	currLevel = load(newLevelPath).instantiate();
	initiateHUD(currLevel)
	currLevel.connect("level_clear_anim_started", Callable(self, "levelClearAnimationStarted"))
	currLevel.connect("level_complete", Callable(self, "nextLevel"));
	
	if currLevel.player_start_dir == currLevel.PlayerStartDir.LEFT:
		$Player.move_direction = -1
	elif currLevel.player_start_dir == currLevel.PlayerStartDir.RIGHT:
		$Player.move_direction = 1
	
	$LevelHud/StageCompleteMessage.modulate = Color.TRANSPARENT;
	
	if currLevel.get_node_or_null("Entrance") != null:
		$Player.global_position = currLevel.get_node("Entrance").global_position;
	else:
		$Player.position = PLAYER_OFFSCREEN_POS if currLevel is Cutscene else PLAYER_START_POS;
	
	$Player.has_key = false;
	$Player.control_mode = $Player.ControlMode.WAIT_FOR_INPUT_BEFORE_AUTO_RUNNER;
	if $Player.has_method("refresh_hat_from_save"):
		$Player.refresh_hat_from_save()
	$Player/Camera2D.reset_smoothing();
	
	$"LevelBackground/1/BackgroundImage".texture = currLevel.bg_img1;
	$"LevelBackground/2/BackgroundImage".texture = currLevel.bg_img2;
	$"LevelBackground/3/BackgroundImage".texture = currLevel.bg_img3;
	
	$LevelParent.call_deferred("add_child", currLevel);

func resetLevel():
	loadLevel(currLevelIndex);

func nextLevel():
	if currLevelIndex + 2 > SaveManager.data.player.highest_level_unlocked:
		SaveManager.update_data("player", "highest_level_unlocked", currLevelIndex+2)
	currLevelIndex += 1
	loadLevel(currLevelIndex);

func levelClearAnimationStarted():
	var message_tween = get_tree().create_tween();
	
	var tower_index : int = floor(currLevelIndex / 5.0) + 1;
	var stage_index : int = currLevelIndex % 5 + 1;
	
	if stage_index == 5:
		$LevelHud/StageCompleteMessage.text = "Tower {0} Complete".format([tower_index]);
	else:
		$LevelHud/StageCompleteMessage.text = "STAGE CLEARED!";
	message_tween.tween_property($LevelHud/StageCompleteMessage, "modulate", Color.WHITE, 0.5);

static func setLevelIndex(index : int):
	currLevelIndex = index;
