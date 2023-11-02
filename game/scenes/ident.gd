extends Control

@onready var anim_player : AnimationPlayer = $AnimationPlayer

func _on_animation_player_animation_finished(anim_name : String) -> void:
	get_tree().change_scene_to_file("res://scenes/intro.tscn")

func shake_it() -> void:
	if Settings.vibration: Input.start_joy_vibration(0, 1.0, 1.0, 0.10)

func _ready() -> void:
	anim_player.play("ident")
