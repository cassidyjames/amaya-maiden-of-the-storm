extends StaticBody2D

class_name Torch

@onready var flame : Sprite2D = $Flame

var health : int = 400

func hit_by_rain() -> void:
	health -= 1
	flame.material.set_shader_parameter("multiplier", health / 400.0)

func _on_area_2d_flame_body_entered(body):
	if body is Player and health > 0:
		body.get_hit_with_rain()

func _ready() -> void:
	flame.material = flame.material.duplicate(true)
