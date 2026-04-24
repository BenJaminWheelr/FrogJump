class_name TimeKeeper

var start_time: float = 0.0
var end_time: float = 0.0
var is_running: bool = false

func start() -> void:
	start_time = Time.get_ticks_msec() / 1000.0
	is_running = true

func stop() -> void:
	end_time = Time.get_ticks_msec() / 1000.0
	is_running = false

func get_elapsed() -> float:
	if is_running:
		return (Time.get_ticks_msec() / 1000.0) - start_time
	return end_time - start_time

static func format_time(total_seconds: float) -> String:
	var hours = int(total_seconds / 3600)
	var minutes = int(total_seconds / 60) % 60
	var seconds = fmod(total_seconds, 60.0)
	
	return "%02d:%02d:%06.3f" % [hours, minutes, seconds]

static func sort_records(a: Dictionary, b: Dictionary) -> bool:
	return a["raw"] < b["raw"]
