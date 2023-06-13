extends WetPushThing

class_name Bucket

const FILL_RATE : float = 0.25

@onready var sprite_level : Sprite2D = $Level

var water_capacity : float = 0.0

func _process(delta : float) -> void:
	if is_wet():
		water_capacity = clamp(water_capacity + (FILL_RATE * delta), 0.0, 1.0)
		sprite_level.frame = water_capacity * 6.0
		mass = 1.0 + (water_capacity * 3.0)
