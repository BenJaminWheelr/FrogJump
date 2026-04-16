extends CanvasLayer

@export_group("Distance Progress")
@export var progress_bar: TextureProgressBar
@export var player: Node2D
@export var finish_line: Goal
@export var finish_icon: TextureRect

var start_y: float
var total_dist: float

func _ready():
	if player and finish_line and progress_bar:
		start_y = player.global_position.y
		total_dist = start_y - finish_line.global_position.y
		progress_bar.min_value = 0
		progress_bar.max_value = 100
	
func _process(_delta):
	update_progress_bar()

func setup():
	if player and finish_line and progress_bar:
		await get_tree().process_frame
		start_y = player.global_position.y
		total_dist = start_y - finish_line.global_position.y
		progress_bar.value = 0

func update_progress_bar():
	if not player or not finish_line or not progress_bar: 
		return
		
	var current_y = player.global_position.y
	var current_dist = start_y - current_y
	
	var progress = (current_dist / total_dist) * 100.0
	if progress > 98.0:
		progress = 100.0
		
	progress_bar.value = clamp(progress, 0, 100)
	
func reset_level_data():
	await get_tree().process_frame 
	
	if finish_line:
		start_y = player.global_position.y
		total_dist = start_y - finish_line.global_position.y
		
		progress_bar.min_value = 0
		progress_bar.max_value = 100
		progress_bar.value = 0
		
		if finish_icon:
			
			finish_icon.position.y = 0
			finish_icon.position.x = 0
	
