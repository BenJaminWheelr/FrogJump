extends Node2D

const CREDITS_SCENE_PATH = "res://scenes/UI/MainMenu.tscn"

func _ready():
	$AnimationPlayer.play("Cutscene");


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	get_tree().change_scene_to_file(CREDITS_SCENE_PATH);
