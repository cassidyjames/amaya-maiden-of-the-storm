extends Node

const _Level1 : PackedScene = preload("res://levels/level1.tscn")

var level : Node2D
@onready var transition : Sprite2D = $Transition

var transition_amount : float = 0.0

func _on_player_dead() -> void:
	var tween : Tween = create_tween()
	tween.tween_property(self, "transition_amount", 0.0, 0.5)
	await tween.finished
	level.queue_free()
	level = _Level1.instantiate()
	add_child(level)
	tween = create_tween()
	tween.tween_property(self, "transition_amount", 1.0, 0.5)

func _on_level_clear() -> void:
	var tween : Tween = create_tween()
	tween.tween_property(self, "transition_amount", 0.0, 0.5)
	await tween.finished
	level.queue_free()
	level = _Level1.instantiate()
	add_child(level)
	tween = create_tween()
	tween.tween_property(self, "transition_amount", 1.0, 0.5)

func _process(delta : float) -> void:
	transition.material.set_shader_parameter("amount", transition_amount)

func _ready() -> void:
	level = _Level1.instantiate()
	add_child(level)
	var tween : Tween = create_tween()
	tween.tween_property(self, "transition_amount", 1.0, 0.5)
