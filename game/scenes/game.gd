extends Node

const LEVELS : Array = [
	preload("res://levels/level1.tscn"),
	preload("res://levels/level2.tscn")
]

var level : Node2D
@onready var transition : Sprite2D = $Transition

var transition_amount : float = 0.0
var current_level : int = 0

func _on_player_dead() -> void:
	change_level()

func _on_level_clear() -> void:
	current_level = wrapi(current_level + 1, 0, LEVELS.size())
	change_level()

func change_level() -> void:
	var tween : Tween = create_tween()
	tween.tween_property(self, "transition_amount", 0.0, 0.5)
	await tween.finished
	level.global_position.y += 1000
	level.queue_free()
	await get_tree().create_timer(0.5).timeout
	level = LEVELS[current_level].instantiate()
	add_child(level)
	tween = create_tween()
	tween.tween_property(self, "transition_amount", 1.0, 0.5)

func _process(delta : float) -> void:
	transition.material.set_shader_parameter("amount", transition_amount)

func _ready() -> void:
	level = LEVELS[0].instantiate()
	add_child(level)
	var tween : Tween = create_tween()
	tween.tween_property(self, "transition_amount", 1.0, 0.5)
