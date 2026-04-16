class_name Level extends Node2D

signal level_clear_anim_started
signal level_complete

# 2 is further in the background than 1, 3 further than 2
@export var bg_img1 : Texture2D = null;
@export var bg_img2 : Texture2D = null;
@export var bg_img3 : Texture2D = null;

@export var music : AudioStream = null;
@export var ambience : AudioStream = null;

func _ready():
	GlobalAudio.play_music(music);
	GlobalAudio.play_ambience(ambience);

func level_complete_anim_start() -> void:
	level_clear_anim_started.emit();

func level_completed() -> void:
	level_complete.emit();
