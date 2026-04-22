extends CanvasLayer

const LEVEL_CONTAINER = preload("res://scenes/level/LevelContainer.tscn")

@export_group("Settings")
@export var level_window_scene: PackedScene
@export var select_sfx: AudioStream 
@export var slide_duration: float = 0.3
@onready var highest_unlocked_level = SaveManager.data.player.highest_level_unlocked


@export_group("Locked State")
@export var locked_icon: Texture2D 

@export_group("Level List")
@export var levels: Array[LevelData] = []

@onready var scroll_container = $ScrollContainer
@onready var hbox = $ScrollContainer/MarginContainer/HBoxContainer

const DRAG_TAP_CANCEL_DISTANCE := 8.0
const INERTIA_STOP_THRESHOLD := 8.0

var _is_touch_dragging := false
var _touch_drag_index := -1
var _drag_distance_accum := 0.0
var _suppress_next_level_tap := false
var _inertia_velocity := 0.0

@export_group("Touch Inertia")
@export var inertia_strength: float = 1.0
@export var inertia_damping: float = 2400.0

func _ready():
	for child in hbox.get_children():
		child.queue_free()
		
	for i in range(levels.size()):
		var data = levels[i]
		if not data: continue
		var has_level_scene = ResourceLoader.exists("res://scenes/level/%d.tscn" % i, "PackedScene")
		
		var inst = level_window_scene.instantiate()
		hbox.add_child(inst)
		
		var level_number = i + 1
		var label = inst.get_node("Control/Label")
		var icon_rect = inst.get_node("Control/LockedIcon")
		var btn = inst.get_node("Control/TextureButton")
		
		btn.texture_normal = data.thumbnail
		
		if level_number > highest_unlocked_level or not has_level_scene:
			btn.disabled = true
			btn.mouse_default_cursor_shape = Control.CURSOR_ARROW
			btn.modulate = Color(0.3, 0.3, 0.3, 1.0) # Grayed out
			
			label.hide()
			if locked_icon and icon_rect:
				icon_rect.texture = locked_icon
				icon_rect.show()
		else:
			btn.disabled = false
			btn.modulate = Color.WHITE
			
			label.text = str(level_number)
			label.show()
			if icon_rect:
				icon_rect.hide()
				
			btn.pressed.connect(_on_level_selected.bind(i))

	await get_tree().process_frame
	center_on_index(0, true)

func slide_to_index(index: int):
	center_on_index(index, false)

func center_on_index(index: int, instant: bool = false):
	index = clamp(index, 0, levels.size() - 1)
	if hbox.get_child_count() == 0: return
	
	var target_node = hbox.get_child(index)
	var scroll_center = scroll_container.size.x / 2
	var node_center = target_node.size.x / 2
	
	var target_x = target_node.position.x + $ScrollContainer/MarginContainer.get_theme_constant("margin_left")
	var final_x = target_x - scroll_center + node_center
	
	if instant:
		scroll_container.scroll_horizontal = final_x
	else:
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.tween_property(scroll_container, "scroll_horizontal", final_x, slide_duration)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if touch_event.pressed:
			if scroll_container.get_global_rect().has_point(touch_event.position):
				_is_touch_dragging = true
				_touch_drag_index = touch_event.index
				_drag_distance_accum = 0.0
				_inertia_velocity = 0.0
		else:
			if _is_touch_dragging and touch_event.index == _touch_drag_index:
				if _drag_distance_accum >= DRAG_TAP_CANCEL_DISTANCE:
					_suppress_next_level_tap = true
				_is_touch_dragging = false
				_touch_drag_index = -1

	if event is InputEventScreenDrag:
		var drag_event := event as InputEventScreenDrag
		if _is_touch_dragging and drag_event.index == _touch_drag_index:
			_drag_distance_accum += abs(drag_event.relative.x)
			scroll_container.scroll_horizontal -= drag_event.relative.x
			_inertia_velocity = -drag_event.velocity.x * inertia_strength


func _process(delta: float) -> void:
	if _is_touch_dragging:
		return

	if abs(_inertia_velocity) < INERTIA_STOP_THRESHOLD:
		_inertia_velocity = 0.0
		return

	var h_scroll_bar = scroll_container.get_h_scroll_bar()
	var next_scroll = scroll_container.scroll_horizontal + (_inertia_velocity * delta)
	if h_scroll_bar:
		next_scroll = clampf(next_scroll, 0.0, h_scroll_bar.max_value)

	scroll_container.scroll_horizontal = next_scroll
	_inertia_velocity = move_toward(_inertia_velocity, 0.0, inertia_damping * delta)

func _on_level_selected(index : int):
	if _suppress_next_level_tap:
		_suppress_next_level_tap = false
		return

	if not ResourceLoader.exists("res://scenes/level/%d.tscn" % index, "PackedScene"):
		return

	if select_sfx:
		GlobalAudio.play_sfx(select_sfx) 
	
	LevelContainer.setLevelIndex(index);
	get_tree().change_scene_to_packed(LEVEL_CONTAINER);
