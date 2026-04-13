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

var _start_position := Vector2.ZERO
var _move_direction := 1.0
var _player: CharacterBody2D


func _ready():
	_start_position = global_position
	add_to_group("enemies")
	_player = _find_player()


func _physics_process(_delta):
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

	var fallback_player = get_tree().get_current_scene().find_child("frog", true, false)
	if fallback_player is CharacterBody2D:
		return fallback_player as CharacterBody2D

	return null
