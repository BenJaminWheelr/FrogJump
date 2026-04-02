extends Button 

@export var back_sfx: AudioStream

func _ready():
	pressed.connect(_on_back_pressed)

func _on_back_pressed():
	if back_sfx:
		GlobalAudio.play_sfx(back_sfx)
	owner.queue_free()
