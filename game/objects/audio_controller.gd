extends Node

@onready var ambience_thunder : AudioStreamPlayer = $Ambience_Thunder
@onready var ambience_rain : AudioStreamPlayer = $Ambience_Rain
@onready var ambience_ending : AudioStreamPlayer = $Ambience_Ending
@onready var music_dream : AudioStreamPlayer = $Music_Dream

var ambience_started : bool = false

func play_ambience_thunder() -> void:
	ambience_thunder.play()

func play_ambience_rain() -> void:
	ambience_started = true
	ambience_rain.volume_db = -40.0
	ambience_rain.play()
	create_tween().tween_property(ambience_rain, "volume_db", -10.0, 5.0)

func play_ambience_ending() -> void:
	ambience_started = true
	ambience_ending.volume_db = -40.0
	ambience_ending.play()
	create_tween().tween_property(ambience_ending, "volume_db", 0.0, 5.0)

func debug_start_ambience() -> void:
	if ambience_started: return
	ambience_rain.volume_db = -10.0
	ambience_rain.play()
	ambience_thunder.play()

func play_music_dream() -> void:
	if not music_dream.playing:
		music_dream.play()
