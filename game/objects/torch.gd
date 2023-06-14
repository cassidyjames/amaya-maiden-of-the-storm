extends WetPushThing

class_name Torch

const HEALTH_DECR : float = 0.5

@onready var flame : Sprite2D = $Flame
@onready var area_flame : Area2D = $Area2D_Flame

var health : float = 1.0

func _on_area_2d_flame_body_entered(body):
	if body is Player and health > 0:
		body.get_hit_with_rain()

func _physics_process(delta : float) -> void:
	if is_wet():
		health = clamp(health - (HEALTH_DECR * delta), 0.0, 1.0)
		flame.material.set_shader_parameter("multiplier", health)
	for body in area_flame.get_overlapping_bodies():
		if body is Bucket:
			body.get_heated()

func _ready() -> void:
	flame.material = flame.material.duplicate(true)
