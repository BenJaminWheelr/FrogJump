extends CharacterBody2D


enum MovementType {
	STATIONARY,
	SIDE_TO_SIDE,
	UP_AND_DOWN,
}

@export var movement_type := MovementType.STATIONARY
@export var movement_speed := 110.0
@export var horizontal_range := 120.0
@export var vertical_range := 80.0

var _start_position := Vector2.ZERO
var _move_direction := 1.0


func _ready():
	_start_position = global_position


func _physics_process(_delta):
	match movement_type:
		MovementType.STATIONARY:
			velocity = Vector2.ZERO

		MovementType.SIDE_TO_SIDE:
			velocity = Vector2(_move_direction * movement_speed, 0.0)

		MovementType.UP_AND_DOWN:
			velocity = Vector2(0.0, _move_direction * movement_speed)

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
