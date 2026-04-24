extends Control

@export var leaderboardLabel: Label
@export var toggleButton: Button
@export var selectSfx: AudioStream
var levelIndex

func _on_toggle_leaderboard() -> void:
	GlobalAudio.play_sfx(selectSfx)
	$LevelThumbnail.visible = !$LevelThumbnail.visible
	$SpeedrunLeaderboard.visible = !$SpeedrunLeaderboard.visible
	var speedrunRecords = SaveManager.get_speedrun_records(str(levelIndex))
	populate_leaderboard(speedrunRecords)
	toggleButton.text = "BACK" if !$LevelThumbnail.visible else "SPEEDRUNS"

func populate_leaderboard(records: Array) -> void:
	var display_text = ""
	
	for i in range(3):
		var line = str(i + 1) + ". "
		if i < records.size():
			line += records[i]["formatted"]
		else:
			line += "N/A"
		
		display_text += line + "\n"
	
	leaderboardLabel.text = display_text.strip_edges()
	
