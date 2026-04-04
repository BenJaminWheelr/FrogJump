extends Button 

@export var select_sfx: AudioStream
@export_file("*.tscn") var main_menu_scene: String

func _ready():
	pressed.connect(_on_main_menu_pressed)

func _on_main_menu_pressed():
	if select_sfx:
		GlobalAudio.play_sfx(select_sfx)
	
	get_tree().paused = false
	
	get_tree().change_scene_to_file(main_menu_scene)
