extends HBoxContainer
class_name ToggleBase

@export_group("Textures")
@export var unchecked_texture: Texture2D = preload("res://assets/textures/unchecked.tres")
@export var checked_texture: Texture2D = preload("res://assets/textures/checked.tres")

@export_group("Audio")
@export var toggle_sfx: AudioStream = preload("res://assets/audio/uiAccept.wav")

@onready var texture_rect = $TextureRect
@onready var button = $Button

var is_active: bool

func _ready():
	is_active = _get_initial_state()
	button.button_pressed = is_active
	_update_ui(is_active)
	button.pressed.connect(_handle_toggle)

func _handle_toggle():
	is_active = !is_active
	if toggle_sfx and has_node("/root/GlobalAudio"):
		GlobalAudio.play_sfx(toggle_sfx)
	
	_on_toggle_pressed(is_active)
	_update_ui(is_active)

func _update_ui(is_on: bool):
	if texture_rect:
		texture_rect.texture = checked_texture if is_on else unchecked_texture

func _get_initial_state() -> bool:
	return false

func _on_toggle_pressed(_new_state: bool):
	pass
