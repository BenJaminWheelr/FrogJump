extends Button

@export_group("Audio")
@export var select_sfx: AudioStream

@export_group("Scenes")
@export_file("*.tscn") var pause_scene_path: String


func _ready() -> void:
	pressed.connect(_on_item_pressed)

func _on_item_pressed() -> void:
	GlobalAudio.play_sfx(select_sfx)
	var pause_inst = load(pause_scene_path).instantiate()
	add_child(pause_inst)
	_toggle_pause()
	pause_inst.tree_exited.connect(_toggle_pause)
	
func _toggle_pause() -> void:
	if is_inside_tree():
		get_tree().paused = !get_tree().paused
		visible = !visible
	
