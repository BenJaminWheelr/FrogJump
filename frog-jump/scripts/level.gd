class_name Level extends Node2D

signal level_complete

func goal_reached() -> void:
	level_complete.emit()
