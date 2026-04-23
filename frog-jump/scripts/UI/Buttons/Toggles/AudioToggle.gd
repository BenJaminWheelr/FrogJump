extends ToggleBase

func _get_initial_state() -> bool:
	return SaveManager.data.settings.audioEnabled

func _on_toggle_pressed(new_state: bool):
	SaveManager.update_data("settings", "audioEnabled", new_state)
	
	if has_node("/root/GlobalAudio"):
		if "audio_enabled" in GlobalAudio:
			GlobalAudio.audio_enabled = new_state
