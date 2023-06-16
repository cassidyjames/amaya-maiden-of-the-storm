extends Control

const _Game : PackedScene = preload("res://scenes/game.tscn")

@onready var anim_player : AnimationPlayer = $AnimationPlayer

func _on_animation_player_animation_finished(anim_name) -> void:
	get_tree().change_scene_to_packed(_Game)

func start_ambience_rain() -> void:
	AudioController.play_ambience_rain()

func _ready() -> void:
	AudioController.play_ambience_thunder()
	anim_player.play("intro")
