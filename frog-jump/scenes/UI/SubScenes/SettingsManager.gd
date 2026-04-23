extends CanvasLayer


func _on_reset_button_pressed() -> void:
	SaveManager.reset_save_data()
	get_tree().change_scene_to_file("res://scenes/UI/MainMenu.tscn")
