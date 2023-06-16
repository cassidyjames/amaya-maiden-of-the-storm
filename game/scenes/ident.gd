extends Control

@onready var anim_player : AnimationPlayer = $AnimationPlayer

func _on_animation_player_animation_finished(anim_name : String) -> void:
	get_tree().change_scene_to_file("res://scenes/intro.tscn")

func _ready() -> void:
	anim_player.play("ident")
