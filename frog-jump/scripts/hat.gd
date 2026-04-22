extends Area2D

const PLAYER_FOLLOW_SPEED = 4.5

@export var target: Node2D = null
@export var follow_speed: float = 15
@export var float_offset: Vector2 = Vector2(0, -35)  # Offset above player's head
@export var bob_height: float = 10.0
@export var bob_speed: float = 2.5
@export var follow_delay: float = 0.25

var bob_time: float = 0.0
var delayed_target_position: Vector2
var has_delayed_target_position: bool = false

func _ready():
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("float")
	has_delayed_target_position = false


func _process(delta: float) -> void:
	bob_time += delta
	if target != null:
		var bob_offset = Vector2(0, sin(bob_time * bob_speed) * bob_height)
		var target_pos = target.global_position + float_offset + bob_offset
		if not has_delayed_target_position:
			delayed_target_position = target_pos
			has_delayed_target_position = true
		delayed_target_position = delayed_target_position.lerp(target_pos, follow_delay)
		global_position = global_position.lerp(delayed_target_position, follow_speed * delta)


func hide_temporarily() -> void:
	visible = false


func show_again() -> void:
	visible = true


func set_hat_sprite(texture: Texture2D) -> void:
	"""Change the hat sprite based on what's unlocked."""
	if has_node("Sprite2D"):
		$Sprite2D.texture = texture
		$Sprite2D.visible = true
