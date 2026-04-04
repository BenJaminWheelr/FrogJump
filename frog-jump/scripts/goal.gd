extends Area2D

signal goal_reached

func _on_body_entered(_body: Node2D) -> void:
	goal_reached.emit()
