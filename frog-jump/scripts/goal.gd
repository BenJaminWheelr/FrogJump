extends Area2D

const PLAYER_IN_DOOR_OFFSET = Vector2(0, 16);

signal goal_reached
signal goal_animation_finished

var player : Player = null;

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body;
		goal_reached.emit()
		animate();
	
func animate():
	if player != null:
		player.set_animation("Float");
		player.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED);
	$AnimationPlayer.play("DoorOpen");

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "DoorOpen":
		if player != null:
			var player_pos_tween = get_tree().create_tween();
			player_pos_tween.connect("finished", Callable($AnimationPlayer, "play").bind("DoorClose"));
			player_pos_tween.tween_property(player, "global_position", self.global_position + PLAYER_IN_DOOR_OFFSET, 0.5);
		else:
			$AnimationPlayer.play("DoorClose");
	if anim_name == "DoorClose":
		if player != null:
			player.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT);
		goal_animation_finished.emit();
