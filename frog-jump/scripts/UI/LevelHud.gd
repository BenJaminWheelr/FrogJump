extends CanvasLayer

@export_group("Distance Progress")
@export var progress_bar: TextureProgressBar
@export var player: Node2D
@export var finish_line: Node2D
@export var isDoorLocked: bool = false
@export var highest_point: Marker2D
@export var key: Area2D

var start_y: float
var end_y: float
var total_dist: float
var display_max_dist: float # The distance used for the 100% bar fill

var icon_layer: Node2D

var key_icon: AnimatedSprite2D
var door_icon: Sprite2D
var locked_door_icon: Sprite2D

var key_start_pos: Vector2
var door_start_pos: Vector2
var locked_door_start_pos: Vector2

var shouldUpdate: bool

func _ready():
	icon_layer = progress_bar.get_node("IconLayer")

	key_icon = icon_layer.get_node("KeySprite")
	door_icon = icon_layer.get_node("DoorSprite")
	locked_door_icon = icon_layer.get_node("LockedDoorSprite")
	
	key_start_pos = key_icon.position
	door_start_pos = door_icon.position
	locked_door_start_pos = locked_door_icon.position

func setup():
	if not player or not progress_bar:
		return

	await get_tree().process_frame

	start_y = player.global_position.y
	shouldUpdate = true
	var candidates = []
	if highest_point:
		candidates.append(highest_point.global_position.y)
	if finish_line:
		candidates.append(finish_line.global_position.y)
	if key:
		candidates.append(key.global_position.y)
	if not finish_line:
		progress_bar.visible = false
	else:
		progress_bar.visible = true

	if candidates.size() > 0:
		end_y = candidates.min()
	else:
		end_y = start_y - 100.0

	# total_dist is the distance to the absolute furthest point for icon scaling
	total_dist = start_y - end_y
	
	# display_max_dist is the distance to the highest_point specifically for bar fill
	if highest_point:
		display_max_dist = start_y - highest_point.global_position.y
	else:
		display_max_dist = total_dist

	progress_bar.min_value = 0
	progress_bar.max_value = 100
	progress_bar.value = 0

	_update_icons()

func _process(_delta):
	update_progress_bar()
	_update_icons()

func update_progress_bar():
	if not player or display_max_dist == 0 or !shouldUpdate:
		return

	var current_dist = start_y - player.global_position.y
	var progress = (current_dist / display_max_dist) * 100.0

	if progress_bar.value <= 95:
		progress_bar.value = 100
	progress_bar.value = clamp(progress, 0.0, 100.0)

func _update_icons():
	if total_dist == 0:
		return

	var bar_length = progress_bar.size.x

	if key and key_icon:
		key_icon.visible = true
		if not key_icon.is_playing():
			key_icon.play("KeySpin")
		_position_icon(key_icon, key_start_pos, key.global_position.y, bar_length)
	elif key_icon:
		key_icon.visible = false

	if finish_line:
		if isDoorLocked:
			if locked_door_icon:
				locked_door_icon.visible = true
				_position_icon(locked_door_icon, locked_door_start_pos, finish_line.global_position.y, bar_length)
			if door_icon:
				door_icon.visible = false
		else:
			if door_icon:
				door_icon.visible = true
				_position_icon(door_icon, door_start_pos, finish_line.global_position.y, bar_length)
			if locked_door_icon:
				locked_door_icon.visible = false

func _position_icon(icon: Node2D, anchor_pos: Vector2, world_y: float, bar_length: float):
	if not icon or total_dist == 0:
		return

	var t = (start_y - world_y) / total_dist
	t = clamp(t, 0.0, 1.0)

	var relative_offset = t * bar_length
	# We use x because i rotated the sprites by 90 deg
	icon.position.x = anchor_pos.x + relative_offset
	
	#print("spawning ", icon.name, " at pos: ", icon.position, " | world_y: ", world_y, " | t: ", t)
