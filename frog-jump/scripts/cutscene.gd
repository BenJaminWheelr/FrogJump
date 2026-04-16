class_name Cutscene extends Level


func _ready():
	$AnimationPlayer.play("Cutscene");

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	level_completed();
