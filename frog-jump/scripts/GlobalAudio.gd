extends Node

var audio_enabled: bool = false

func play_sfx(effect: AudioStream):
	if effect and audio_enabled:
		var player = AudioStreamPlayer.new()
		add_child(player)
		player.stream = effect
		player.play()
		player.finished.connect(player.queue_free)
