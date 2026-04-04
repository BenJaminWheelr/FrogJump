extends Node

var audio_enabled: bool = true:
	set(value):
		audio_enabled = value
		if audio_enabled:
			_resume_bg()
		else:
			stop_all_bg()

var current_music_stream: AudioStream
var current_ambience_stream: AudioStream
var current_music_volume: float = 0.0
var current_ambience_volume: float = 0.0

@onready var music_player = AudioStreamPlayer.new()
@onready var ambience_player = AudioStreamPlayer.new()

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
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
	current_music_stream = stream
	current_music_volume = volume
	
	if not audio_enabled:
		return
		
	if music_player.stream == stream and music_player.playing:
		return
		
	music_player.stream = stream
	music_player.volume_db = volume
	music_player.play()

func play_ambience(stream: AudioStream, volume: float = 0.0):
	current_ambience_stream = stream
	current_ambience_volume = volume
	
	if not audio_enabled:
		return
		
	if ambience_player.stream == stream and ambience_player.playing:
		return
		
	ambience_player.stream = stream
	ambience_player.volume_db = volume
	ambience_player.play()

func _resume_bg():
	if current_music_stream:
		play_music(current_music_stream, current_music_volume)
	if current_ambience_stream:
		play_ambience(current_ambience_stream, current_ambience_volume)

func stop_all_bg():
	music_player.stop()
	ambience_player.stop()
