extends HBoxContainer

@export_group("Textures")
@export var unchecked_texture: Texture2D
@export var checked_texture: Texture2D

@export_group("Audio")
@export var toggle_sfx: AudioStream

@onready var texture_rect = $TextureRect
@onready var button = $Button

var isActive: bool

func _ready():	
	isActive = SaveManager.data.settings.audioEnabled
	button.button_pressed = isActive
	
	_update_ui(isActive)
	
	button.pressed.connect(_on_button_toggled)

func _on_button_toggled():
	isActive = !isActive
	SaveManager.update_data("settings", "audioEnabled", isActive)
	if "audio_enabled" in GlobalAudio:
		GlobalAudio.audio_enabled = isActive
	if toggle_sfx:
		GlobalAudio.play_sfx(toggle_sfx)
	_update_ui(isActive)

func _update_ui(is_on: bool):
	texture_rect.texture = checked_texture if is_on else unchecked_texture
