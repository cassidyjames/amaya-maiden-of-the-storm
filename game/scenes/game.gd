extends Node

const LEVELS : Array = [
	preload("res://levels/level1.tscn"),
	preload("res://levels/level2.tscn"),
	preload("res://levels/level3.tscn"),
	preload("res://levels/level4.tscn"),
	preload("res://levels/level5.tscn"),
	preload("res://levels/level6.tscn"),
	preload("res://levels/level7.tscn"),
]

var level : Node2D
@onready var transition : Sprite2D = $Transition
@onready var level_indicator : Node2D = $LevelIndicator

var transition_amount : float = 0.0
var current_level : int = 0

func start_level() -> void:
	level = LEVELS[current_level].instantiate()
	add_child(level)
	var tween : Tween = create_tween()
	tween.tween_property(self, "transition_amount", 1.0, 0.5)

func end_level() -> void:
	var tween : Tween = create_tween()
	tween.tween_property(self, "transition_amount", 0.0, 0.5)
	await tween.finished
	level.global_position.y += 1000
	level.queue_free()

func _on_level_clear() -> void:
	current_level = wrapi(current_level + 1, 0, LEVELS.size())
	end_level()
	level_indicator.show()
	level_indicator.play(current_level)
	await get_tree().create_timer(2.25).timeout
	start_level()
	await get_tree().create_timer(1.0).timeout
	level_indicator.hide()

func _on_player_dead() -> void:
	await end_level()
	await get_tree().create_timer(0.5).timeout
	start_level()

func _process(delta : float) -> void:
	transition.material.set_shader_parameter("amount", transition_amount)

func _ready() -> void:
	level = LEVELS[0].instantiate()
	add_child(level)
	var tween : Tween = create_tween()
	tween.tween_property(self, "transition_amount", 1.0, 0.5)
