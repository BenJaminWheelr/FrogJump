extends CharacterBody2D


enum ControlMode {
	AUTO_RUNNER,
	DRAG_LAUNCH,
}


const SPEED = 300.0
const JUMP_VELOCITY = -550.0
const GRAVITY_MULTIPLIER = 1.35
const MIN_DRAG_DISTANCE = 12.0

@export var play_area_shape_path: NodePath = NodePath("../play-area/CollisionShape2D")
@export var control_mode := ControlMode.AUTO_RUNNER
@export var toggle_mode_keycode: Key = KEY_TAB
@export var launch_force := 5.5
@export var max_pull_distance := 180.0
@export var floor_friction := 1600.0

var move_direction := 1.0
var has_play_area_bounds := false
var play_area_left := 0.0
var play_area_right := 0.0
var is_dragging := false
var drag_mouse_position := Vector2.ZERO


func _ready():
	_cache_play_area_bounds()
	drag_mouse_position = global_position
	_announce_control_mode()


func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == toggle_mode_keycode:
		_toggle_control_mode()
		return

	if control_mode != ControlMode.DRAG_LAUNCH:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if is_on_floor():
				is_dragging = true
				drag_mouse_position = get_global_mouse_position()
				velocity = Vector2.ZERO
				queue_redraw()
		elif is_dragging:
			drag_mouse_position = get_global_mouse_position()
			_launch_from_drag()
			is_dragging = false
			queue_redraw()

	if event is InputEventMouseMotion and is_dragging:
		drag_mouse_position = get_global_mouse_position()
		queue_redraw()


func _cache_play_area_bounds():
	var shape_node = get_node_or_null(play_area_shape_path) as CollisionShape2D
	if shape_node == null:
		has_play_area_bounds = false
		return

	var rect_shape = shape_node.shape as RectangleShape2D
	if rect_shape == null:
		has_play_area_bounds = false
		return

	var half_width = rect_shape.size.x * shape_node.global_scale.x * 0.5
	play_area_left = shape_node.global_position.x - half_width
	play_area_right = shape_node.global_position.x + half_width
	has_play_area_bounds = true


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * GRAVITY_MULTIPLIER

	if control_mode == ControlMode.AUTO_RUNNER:
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		velocity.x = move_direction * SPEED
	else:
		if is_dragging:
			velocity = Vector2.ZERO
		else:
			velocity.x = move_direction * SPEED

	move_and_slide()

	if has_play_area_bounds and (global_position.x < play_area_left or global_position.x > play_area_right):
		move_direction *= -1.0
		global_position.x = clamp(global_position.x, play_area_left, play_area_right)


func _draw():
	if control_mode != ControlMode.DRAG_LAUNCH or not is_dragging:
		return

	var pull_vector = (global_position - drag_mouse_position).limit_length(max_pull_distance)
	var drag_line_end = drag_mouse_position - global_position
	draw_line(Vector2.ZERO, drag_line_end, Color(0.9, 0.3, 0.2, 0.8), 3.0)
	draw_line(Vector2.ZERO, pull_vector, Color(0.2, 0.9, 0.4, 0.9), 4.0)


func _toggle_control_mode():
	if control_mode == ControlMode.AUTO_RUNNER:
		control_mode = ControlMode.DRAG_LAUNCH
		velocity.x = 0.0
	else:
		control_mode = ControlMode.AUTO_RUNNER
		move_direction = 1.0 if velocity.x >= 0.0 else -1.0

	is_dragging = false
	queue_redraw()
	_announce_control_mode()


func _announce_control_mode():
	if control_mode == ControlMode.AUTO_RUNNER:
		print("Control mode: AUTO_RUNNER (Space = jump)")
	else:
		print("Control mode: DRAG_LAUNCH (Click and drag to launch)")


func _launch_from_drag():
	var pull_vector = global_position - drag_mouse_position
	if pull_vector.length() < MIN_DRAG_DISTANCE:
		return

	move_direction = 1.0 if pull_vector.x >= 0.0 else -1.0
	velocity = pull_vector.limit_length(max_pull_distance) * launch_force
