extends Node

var audio_enabled: bool = false

@onready var music_player = AudioStreamPlayer.new()
@onready var ambience_player = AudioStreamPlayer.new()

func _ready():
	# Setup persistent players
	add_child(music_player)
	add_child(ambience_player)
	
	music_player.bus = "Music"
	ambience_player.bus = "Ambience"

func play_sfx(effect: AudioStream):
	if effect and audio_enabled:
		var player = AudioStreamPlayer.new()
		add_child(player)
		player.stream = effect
		player.bus = "SFX"
		player.play()
		player.finished.connect(player.queue_free)

func play_music(stream: AudioStream, volume: float = 0.0):
	if music_player.stream == stream and music_player.playing:
		return
	music_player.stream = stream
	music_player.volume_db = volume
	music_player.play()

func play_ambience(stream: AudioStream, volume: float = 0.0):
	if ambience_player.stream == stream and ambience_player.playing:
		return
	ambience_player.stream = stream
	ambience_player.volume_db = volume
	ambience_player.play()

func stop_all_bg():
	music_player.stop()
	ambience_player.stop()
