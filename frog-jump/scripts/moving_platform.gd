class_name MovingPlatform extends CharacterBody2D

@export_range(3, 512) var width : int = 32;
@export var set_vel : Vector2 = Vector2.ZERO;

func _ready():
	velocity = set_vel;
	
	var midW : int = width - 2;
	$Mid.region_rect.size.x = midW;
	$Right.position.x = midW / 2.0;
	$Left.position.x = -midW / 2.0;
	$CollisionShape2D.shape.size.x = width;

func _physics_process(delta: float) -> void:
	self.position += velocity * delta;
