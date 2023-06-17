extends Node

@onready var ambience_thunder : AudioStreamPlayer = $Ambience_Thunder
@onready var ambience_rain : AudioStreamPlayer = $Ambience_Rain
@onready var ambience_ending : AudioStreamPlayer = $Ambience_Ending
@onready var music_dream : AudioStreamPlayer = $Music_Dream
@onready var music_wind : AudioStreamPlayer = $Music_Wind
@onready var audio_player_die : AudioStreamPlayer = $Audio_PlayerDie

enum MusicState {WAITING, PLAYING_WIND, WIND_DONE, PLAYING_DREAM, DREAM_DONE}

var music_state : int = MusicState.WAITING
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

func duck_ambience_next_level() -> void:
	var tween : Tween = create_tween()
	tween.tween_property(ambience_rain, "volume_db", -40.0, 1.0)
	tween.tween_interval(1.0)
	tween.tween_property(ambience_rain, "volume_db", -10.0, 1.0)

func duck_ambience_restart_level() -> void:
	var tween : Tween = create_tween()
	tween.tween_property(ambience_rain, "volume_db", -40.0, 0.5)
	tween.tween_interval(0.5)
	tween.tween_property(ambience_rain, "volume_db", -10.0, 0.5)

func stop_game_ambience() -> void:
	var tween : Tween = create_tween().set_parallel()
	tween.tween_property(ambience_thunder, "volume_db", -40.0, 1.0)
	tween.tween_property(ambience_rain, "volume_db", -40.0, 1.0)

func _on_level_started() -> void:
	match music_state:
		MusicState.WAITING:
			music_wind.play()
			music_state = MusicState.PLAYING_WIND
		MusicState.WIND_DONE:
			music_dream.play()
			music_state = MusicState.PLAYING_DREAM

func _on_music_wind_finished() -> void:
	music_state = MusicState.WIND_DONE

func _on_music_dream_finished() -> void:
	music_state = MusicState.DREAM_DONE

func play_player_die() -> void:
	audio_player_die.play()
