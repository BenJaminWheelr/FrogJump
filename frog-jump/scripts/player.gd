class_name Player extends CharacterBody2D


enum ControlMode {
	AUTO_RUNNER,
	WAIT_FOR_INPUT_BEFORE_AUTO_RUNNER,
}

@export var SPEED = 300.0
@export var JUMP_VELOCITY = -550.0
@export var GRAVITY_MULTIPLIER = 1.35

@export var control_mode := ControlMode.AUTO_RUNNER

@export var enemy_group_name := "enemies"
@export var enemy_bounce_velocity := -260.0

@export var move_direction := 1.0

signal lost_key
var has_key : bool = false;

@export_group("Audio")
@export var jump_sfx: AudioStream

func _ready():
	add_to_group("player")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * GRAVITY_MULTIPLIER

	if control_mode == ControlMode.AUTO_RUNNER:
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			if jump_sfx:
				GlobalAudio.play_sfx(jump_sfx)
		if !Input.is_action_pressed("ui_accept") and velocity.y < 0:
			velocity.y = 0
		velocity.x = move_direction * SPEED
	elif control_mode == ControlMode.WAIT_FOR_INPUT_BEFORE_AUTO_RUNNER:
		velocity.x = 0;
		if Input.is_action_just_pressed("ui_accept"):
			control_mode = ControlMode.AUTO_RUNNER;

	move_and_slide()

	var hit_enemy_body := false
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider != null and collider.is_in_group(enemy_group_name):
			if _is_enemy_damage_collision(collision):
				_remove_enemy(collider)
				break

			hit_enemy_body = true
			break

		# flip direction on side collision
		if collision.get_normal().x != 0:
			move_direction *= -1
			break

	if hit_enemy_body:
		_reset_level_after_enemy_hit()
 
func _process(_delta: float) -> void:
	animate();

func animate():
	$FrogSprite.flip_h = move_direction < 0;
	
	if control_mode == ControlMode.WAIT_FOR_INPUT_BEFORE_AUTO_RUNNER:
		set_animation("Idle");
	elif is_on_floor():
		set_animation("Run");
	elif velocity.y < 0:
		set_animation("Jump");
	elif ( $AnimationPlayer.current_animation != "Jump" &&
		   $AnimationPlayer.current_animation != "FreeFall"):
		set_animation("Fall");
		

func set_animation(val : String):
	if ($AnimationPlayer.has_animation(val) &&
		$AnimationPlayer.current_animation != val):
			$AnimationPlayer.play(val);

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Jump":
		set_animation("Fall");
	if anim_name == "Fall":
		set_animation("FreeFall");

func _is_enemy_damage_collision(collision: KinematicCollision2D) -> bool:
	var collider = collision.get_collider() as CollisionObject2D
	if collider == null:
		return false

	var collider_shape_index = collision.get_collider_shape_index()
	if collider_shape_index < 0:
		return false

	var shape_owner = collider.shape_find_owner(collider_shape_index)
	if shape_owner == -1:
		return false

	var shape_owner_node = collider.shape_owner_get_owner(shape_owner) as Node
	return shape_owner_node != null and shape_owner_node.name == "damage"


func _remove_enemy(enemy: Object):
	velocity.y = min(velocity.y, enemy_bounce_velocity)
	queue_redraw()

	if enemy is Node:
		(enemy as Node).call_deferred("queue_free")


func _reset_level_after_enemy_hit():
	var node = get_parent()
	while node != null:
		if node.has_method("resetLevel"):
			node.call_deferred("resetLevel")
			return
		node = node.get_parent()

	get_tree().call_deferred("reload_current_scene")


func _on_key_detection_area_area_entered(_area: Area2D) -> void:
	has_key = true;

func drop_key():
	has_key = false;
	lost_key.emit();


func _on_instakill_detection_area_body_entered(_body: Node2D) -> void:
	_reset_level_after_enemy_hit()
