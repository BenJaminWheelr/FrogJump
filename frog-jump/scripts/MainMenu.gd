extends Control

@export_group("Buttons")
@export var play_button: Button
@export var settings_button: Button
@export var credits_button: Button
@export var exit_button: Button

@export_group("Audio")
@export var select_sfx: AudioStream
@export var accept_sfx: AudioStream

@export_group("Scenes")
@export_file("*.tscn") var play_scene_path: String
@export_file("*.tscn") var credits_scene_path: String
@export_file("*.tscn") var settings_scene_path: String

func _ready():
	if play_button:
		play_button.pressed.connect(_on_play_pressed)
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
	if credits_button:
		credits_button.pressed.connect(_on_credits_pressed)
	if exit_button:
		exit_button.pressed.connect(_on_exit_pressed)

func _on_play_pressed():
	if _handle_click(play_scene_path, accept_sfx):
		get_tree().change_scene_to_file(play_scene_path)
	
func _on_credits_pressed():
	if _handle_click(credits_scene_path, select_sfx):
		get_tree().change_scene_to_file(credits_scene_path)


func _on_exit_pressed():
	_handle_click("", select_sfx)
	get_tree().quit()
	
func _on_settings_pressed():
	if _handle_click(settings_scene_path, select_sfx):
		var settings_inst = load(settings_scene_path).instantiate()
		add_child(settings_inst)
	_toggle_menu_buttons(false)

func _toggle_menu_buttons(is_visible: bool):
	play_button.get_parent().visible = is_visible

func _handle_click(scene_path: String, sfx: AudioStream) -> bool:
	if sfx == null:
		print("set sfx!")
	else:
		GlobalAudio.play_sfx(sfx)
	
	if scene_path == "":
		print("set scene!")
		return false
		
	return true
