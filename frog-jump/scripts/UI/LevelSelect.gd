extends CanvasLayer

@export_group("Settings")
@export var level_window_scene: PackedScene
@export var select_sfx: AudioStream 
@export var slide_duration: float = 0.3
@export var highest_unlocked_level: int = 1 

@export_group("Locked State")
@export var locked_icon: Texture2D 

@export_group("Level List")
@export var levels: Array[LevelData] = []

@onready var scroll_container = $ScrollContainer
@onready var hbox = $ScrollContainer/MarginContainer/HBoxContainer

func _ready():
	for child in hbox.get_children():
		child.queue_free()
		
	for i in range(levels.size()):
		var data = levels[i]
		if not data: continue
		
		var inst = level_window_scene.instantiate()
		hbox.add_child(inst)
		
		var level_number = i + 1
		var label = inst.get_node("Control/Label")
		var icon_rect = inst.get_node("Control/LockedIcon")
		var btn = inst.get_node("Control/TextureButton")
		
		btn.texture_normal = data.thumbnail
		
		if level_number > highest_unlocked_level:
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
				
			btn.pressed.connect(_on_level_selected.bind(data.scene_path))

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

func _on_level_selected(path: String):
	if path == "": return
	if select_sfx:
		GlobalAudio.play_sfx(select_sfx) 
	get_tree().change_scene_to_file(path)
