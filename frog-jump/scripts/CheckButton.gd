extends HBoxContainer

@export_group("Textures")
@export var unchecked_texture: Texture2D
@export var checked_texture: Texture2D

@export_group("Audio")
@export var toggle_sfx: AudioStream

@onready var texture_rect = $TextureRect
@onready var button = $Button

var isActive

func _ready():	
	isActive = GlobalAudio.audio_enabled if "audio_enabled" in GlobalAudio else false
	button.button_pressed = isActive
	
	_update_ui(isActive)
	
	button.pressed.connect(_on_button_toggled)

func _on_button_toggled():
	GlobalAudio.audio_enabled = not isActive
	isActive = not isActive
	if toggle_sfx:
		GlobalAudio.play_sfx(toggle_sfx)
	_update_ui(isActive)

func _update_ui(is_on: bool):
	if is_on:
		texture_rect.texture = checked_texture
	else:
		texture_rect.texture = unchecked_texture
