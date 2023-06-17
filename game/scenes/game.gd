extends Node

const _PauseScreen : PackedScene = preload("res://objects/ui/pause_screen.tscn")

const LEVELS : Array = [
	preload("res://levels/level1.tscn"),
	preload("res://levels/level2.tscn"),
	preload("res://levels/level3.tscn"),
	preload("res://levels/level4.tscn"),
	preload("res://levels/level5.tscn"),
	preload("res://levels/level6.tscn"),
	preload("res://levels/level7.tscn"),
	preload("res://levels/level8.tscn"),
]

var level : Node2D
@onready var transition : Sprite2D = $Transition
@onready var level_indicator : Node2D = $LevelIndicator
@onready var canvas_layer : CanvasLayer = $CanvasLayer

enum State {GAMEPLAY, NON_GAMEPLAY}

var transition_amount : float = 0.0
var current_level : int = 0
var current_state : int = State.GAMEPLAY

var level_time : float
var level_deaths : int = 0
var level_shifts : int

func start_level() -> void:
	level = LEVELS[current_level].instantiate()
	add_child(level)
	var tween : Tween = create_tween()
	tween.tween_property(self, "transition_amount", 1.0, 0.5)
	level_time = 0.0
	level_shifts = 0
	current_state = State.GAMEPLAY

func end_level() -> void:
	current_state = State.NON_GAMEPLAY
	var tween : Tween = create_tween()
	tween.tween_property(self, "transition_amount", 0.0, 0.5)
	await tween.finished
	level.global_position.y += 1000
	level.queue_free()

func _on_level_clear() -> void:
	GameSession.level_history[current_level] = {
		"time": level_time, "deaths": level_deaths, "shifts": level_shifts
	}
	end_level()
	if current_level == 7:
		AudioController.stop_game_ambience()
		level_indicator.show()
		level_indicator.play_ending()
		await get_tree().create_timer(11.0).timeout
		get_tree().change_scene_to_file("res://scenes/ending.tscn")
	else:
		AudioController.duck_ambience_next_level()
		current_level += 1
		level_indicator.show()
		level_indicator.play(current_level)
		await get_tree().create_timer(2.25).timeout
		start_level()
		await get_tree().create_timer(1.0).timeout
		level_indicator.hide()
		AudioController._on_level_started()

func _on_player_shift() -> void:
	level_shifts += 1

func _on_player_dead() -> void:
	level_deaths += 1
	AudioController.duck_ambience_restart_level()
	await end_level()
	await get_tree().create_timer(0.5).timeout
	start_level()

func _input(event : InputEvent) -> void:
	if current_state != State.GAMEPLAY:
		return
	if event.is_action_pressed("pause"):
		var pause_screen : Control = _PauseScreen.instantiate()
		canvas_layer.add_child(pause_screen)
		get_tree().paused = true

func _process(delta : float) -> void:
	level_time += delta
	transition.material.set_shader_parameter("amount", transition_amount)

func _ready() -> void:
	AudioController.debug_start_ambience()
	AudioController._on_level_started()
	start_level()
