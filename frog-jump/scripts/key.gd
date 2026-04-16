extends Area2D

const FOLLOW_SPEED = 8;

var target : Player = null;

func _ready():
	$AnimatedSprite.play("spin");

func _process(delta: float) -> void:
	if target != null:
		global_position = global_position.lerp(target.global_position, FOLLOW_SPEED * delta)


func _on_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player and target == null:
		target = area.get_parent();
		area.get_parent().connect("lost_key", Callable(self, "queue_free"));
