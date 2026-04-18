extends Area2D

const PLAYER_FOLLOW_SPEED = 8;

@export var target : Node2D = null;
@export var follow_speed = 8;

func _ready():
	$AnimatedSprite.play("spin");

func _process(delta: float) -> void:
	if target != null:
		global_position = global_position.lerp(target.global_position, follow_speed * delta)


func _on_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player && (target == null || !target is Player):
		target = area.get_parent();
		area.get_parent().connect("lost_key", Callable(self, "queue_free"));
		follow_speed = PLAYER_FOLLOW_SPEED;
