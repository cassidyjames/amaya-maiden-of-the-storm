extends Control

@onready var label_level_times : Label = $ColorRect/Label_LevelTimes
@onready var label_level_shifts : Label = $ColorRect/Label_LevelShifts
@onready var label_level_deaths : Label = $ColorRect/Label_LevelDeaths
@onready var anim_player : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	label_level_times.text = ""
	label_level_shifts.text = ""
	label_level_deaths.text = ""
	for level in GameSession.level_history:
		var data : Dictionary = GameSession.level_history[level]
		var minutes : float = data["time"] / 60
		var seconds : float = fmod(data["time"], 60.0)
		label_level_times.text += "%02d:%02d\n" % [minutes, seconds]
		label_level_shifts.text += str(data["shifts"]) + "\n"
		label_level_deaths.text += str(data["deaths"]) + "\n"
	AudioController.play_ambience_ending()
	anim_player.play("ending")