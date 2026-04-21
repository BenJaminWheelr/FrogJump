extends Node2D

@export var platform_range : Vector2 = Vector2.ZERO;

func _process(_delta):
	for platform in get_children():
		if !platform is MovingPlatform:
			continue;
		if ((platform.position.x + platform.width / 2.0 > platform_range.x / 2.0 &&
			platform.velocity.x > 0) ||
			(platform.position.x - platform.width / 2.0 < -platform_range.x / 2.0 &&
			platform.velocity.x < 0)):
			platform.velocity.x *= -1;
		if ((platform.position.y > platform_range.y / 2.0 && platform.velocity.y > 0) ||
			(platform.position.y < -platform_range.y / 2.0 && platform.velocity.y < 0)):
			platform.velocity.y *= -1;
