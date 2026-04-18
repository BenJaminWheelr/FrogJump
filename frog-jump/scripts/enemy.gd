@tool
extends CharacterBody2D


enum MovementType {
	STATIONARY,
	SIDE_TO_SIDE,
	UP_AND_DOWN,
	CHASE_PLAYER_SAME_PLATFORM,
}

@export var movement_type := MovementType.STATIONARY
@export var movement_speed := 110.0
@export var horizontal_range := 120.0
@export var vertical_range := 80.0
@export var chase_speed := 65.0
@export var chase_range := 280.0
@export var same_platform_y_tolerance := 28.0
@export var chase_deadzone := 6.0
@export var player_group_name := "player"
@export var enemy_texture: Texture2D:
	set(value):
		_enemy_texture = value
		_refresh_enemy_sprite()
	get:
		return _enemy_texture

var _start_position := Vector2.ZERO
var _move_direction := 1.0
var _player: CharacterBody2D
var _enemy_texture: Texture2D


func _enter_tree():
	if Engine.is_editor_hint():
		call_deferred("_refresh_enemy_sprite")


func _ready():
	_refresh_enemy_sprite()

	if Engine.is_editor_hint():
		return

	_start_position = global_position
	add_to_group("enemies")
	_player = _find_player()


func _physics_process(delta):
	if Engine.is_editor_hint():
		return

	match movement_type:
		MovementType.STATIONARY:
			velocity = Vector2.ZERO

		MovementType.SIDE_TO_SIDE:
			velocity = Vector2(_move_direction * movement_speed, 0.0)

		MovementType.UP_AND_DOWN:
			velocity = Vector2(0.0, _move_direction * movement_speed)

		MovementType.CHASE_PLAYER_SAME_PLATFORM:
			velocity = Vector2.ZERO
			if _player == null or not is_instance_valid(_player):
				_player = _find_player()

			if _player != null:
				var to_player = _player.global_position - global_position
				var on_same_platform_band = abs(to_player.y) <= same_platform_y_tolerance
				var in_chase_range = abs(to_player.x) <= chase_range
				if on_same_platform_band and in_chase_range and abs(to_player.x) > chase_deadzone:
					velocity.x = sign(to_player.x) * chase_speed

	move_and_slide()

	if movement_type == MovementType.SIDE_TO_SIDE and horizontal_range > 0.0:
		var horizontal_offset = global_position.x - _start_position.x
		if _move_direction > 0.0 and horizontal_offset >= horizontal_range:
			global_position.x = _start_position.x + horizontal_range
			_move_direction = -1.0
		elif _move_direction < 0.0 and horizontal_offset <= -horizontal_range:
			global_position.x = _start_position.x - horizontal_range
			_move_direction = 1.0

	if movement_type == MovementType.UP_AND_DOWN and vertical_range > 0.0:
		var vertical_offset = global_position.y - _start_position.y
		if _move_direction > 0.0 and vertical_offset >= vertical_range:
			global_position.y = _start_position.y + vertical_range
			_move_direction = -1.0
		elif _move_direction < 0.0 and vertical_offset <= -vertical_range:
			global_position.y = _start_position.y - vertical_range
			_move_direction = 1.0


func _find_player() -> CharacterBody2D:
	var grouped_player = get_tree().get_first_node_in_group(player_group_name)
	if grouped_player is CharacterBody2D:
		return grouped_player as CharacterBody2D

	var current_scene = get_tree().get_current_scene()
	if current_scene == null:
		return null

	var fallback_player = current_scene.find_child("frog", true, false)
	if fallback_player is CharacterBody2D:
		return fallback_player as CharacterBody2D

	return null


func _refresh_enemy_sprite():
	var sprite = _get_enemy_sprite()
	if sprite == null:
		return

	if _enemy_texture == null:
		_enemy_texture = sprite.texture

	if _enemy_texture != null:
		sprite.texture = _enemy_texture

	if sprite.texture == null:
		return

	var collision_bounds = _get_collision_bounds()
	if collision_bounds.size == Vector2.ZERO:
		return

	if sprite.centered:
		sprite.position = collision_bounds.position + collision_bounds.size * 0.5
	else:
		sprite.position = collision_bounds.position

	var target_size = collision_bounds.size
	if target_size.x <= 0.0 or target_size.y <= 0.0:
		return

	var texture_size = sprite.texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return

	var sign_x = _nonzero_sign(sprite.scale.x)
	var sign_y = _nonzero_sign(sprite.scale.y)

	sprite.scale = Vector2(
		(target_size.x / texture_size.x) * sign_x,
		(target_size.y / texture_size.y) * sign_y
	)


func _get_collision_bounds() -> Rect2:
	var found_any := false
	var min_x := 0.0
	var min_y := 0.0
	var max_x := 0.0
	var max_y := 0.0

	for child in get_children():
		var collision_shape = child as CollisionShape2D
		if collision_shape == null or collision_shape.disabled:
			continue
		if not (collision_shape.shape is RectangleShape2D):
			continue

		var rectangle = collision_shape.shape as RectangleShape2D
		var shape_size = rectangle.size * _abs_vec2(collision_shape.scale)
		if shape_size.x <= 0.0 or shape_size.y <= 0.0:
			continue

		var top_left = collision_shape.position - shape_size * 0.5
		var bottom_right = top_left + shape_size

		if not found_any:
			min_x = top_left.x
			min_y = top_left.y
			max_x = bottom_right.x
			max_y = bottom_right.y
			found_any = true
		else:
			min_x = min(min_x, top_left.x)
			min_y = min(min_y, top_left.y)
			max_x = max(max_x, bottom_right.x)
			max_y = max(max_y, bottom_right.y)

	if found_any:
		return Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))

	var sprite = _get_enemy_sprite()
	if sprite != null and sprite.texture != null:
		var sprite_size = sprite.texture.get_size() * _abs_vec2(sprite.scale)
		var sprite_top_left = sprite.position
		if sprite.centered:
			sprite_top_left -= sprite_size * 0.5
		return Rect2(sprite_top_left, sprite_size)

	return Rect2(Vector2.ZERO, Vector2.ZERO)


func _get_enemy_sprite() -> Sprite2D:
	return get_node_or_null(^"Sprite2D") as Sprite2D


func _abs_vec2(value: Vector2) -> Vector2:
	return Vector2(abs(value.x), abs(value.y))


func _nonzero_sign(value: float) -> float:
	var direction = sign(value)
	if direction == 0.0:
		return 1.0
	return direction
