extends CanvasLayer

@export var configContainer: VBoxContainer
@export var resetConfirmation: ConfirmationDialog

var warningSfx: AudioStream = preload("res://assets/audio/uiWarning.mp3")
func _ready() -> void:
	resetConfirmation.confirmed.connect(_on_reset_confirmation_confirmed)
	resetConfirmation.canceled.connect(_on_reset_canceled)

func _on_reset_confirmation_confirmed() -> void:
	SaveManager.reset_save_data()
	get_tree().reload_current_scene()

func _on_reset_canceled() -> void:
	toggleConfigContainer()
	
func toggleConfigContainer() -> void:
	configContainer.visible = !configContainer.visible
	
func _on_reset_button_pressed() -> void:
	toggleConfigContainer()
	GlobalAudio.play_sfx(warningSfx)
	resetConfirmation.popup_centered()
