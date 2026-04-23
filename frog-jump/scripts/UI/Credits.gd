extends CanvasLayer

@onready var scroll_container: ScrollContainer = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer

var _is_touch_dragging := false
var _touch_drag_index := -1


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if touch_event.pressed:
			if scroll_container.get_global_rect().has_point(touch_event.position):
				_is_touch_dragging = true
				_touch_drag_index = touch_event.index
		else:
			if _is_touch_dragging and touch_event.index == _touch_drag_index:
				_is_touch_dragging = false
				_touch_drag_index = -1

	if event is InputEventScreenDrag:
		var drag_event := event as InputEventScreenDrag
		if _is_touch_dragging and drag_event.index == _touch_drag_index:
			scroll_container.scroll_vertical -= drag_event.relative.y
