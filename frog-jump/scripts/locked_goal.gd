extends Goal

const NO_KEY_TEX = preload("res://assets/textures/door.png");

func _on_body_entered(body: Node2D) -> void:
	if body is Player and body.has_key:
		body.drop_key();
		super._on_body_entered(body);

func _on_animation_player_animation_finished(anim_name: StringName):
	if anim_name == "DoorOpen":
		$DoorSprite.texture = NO_KEY_TEX;
	super._on_animation_player_animation_finished(anim_name);
