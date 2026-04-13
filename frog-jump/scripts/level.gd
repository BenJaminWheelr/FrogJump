class_name Level extends Node2D

signal level_complete

# 2 is further in the background than 1, 3 further than 2
@export var bg_img1 : Texture2D = null;
@export var bg_img2 : Texture2D = null;
@export var bg_img3 : Texture2D = null;

func goal_reached() -> void:
	level_complete.emit()
