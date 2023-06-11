extends StaticBody2D

class_name Bucket

const FILL_RATE : float = 0.25

@onready var sprite_level : Sprite2D = $Level

var water_capacity : float = 0.0
var hit_by_water : float = 0.0

func get_mass() -> float:
	return 1.0 + (water_capacity * 3.0)

func hit_by_rain() -> void:
	hit_by_water = 0.1

func descend(distance : float) -> float:
	var collision : KinematicCollision2D = move_and_collide(Vector2.DOWN * distance)
	if collision == null:
		return 0.0
	else:
		return collision.get_remainder().length()

func _process(delta : float) -> void:
	hit_by_water = clamp(hit_by_water - delta, 0.0, 1.0)
	if hit_by_water > 0.0:
		water_capacity = clamp(water_capacity + (FILL_RATE * delta), 0.0, 1.0)
		sprite_level.frame = water_capacity * 6.0
