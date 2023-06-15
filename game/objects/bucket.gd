extends WetPushThing

class_name Bucket

const FILL_RATE : float = 0.25
const HEAT_RATE : float = 0.2
const COOL_RATE : float = 0.1
const BOIL_RATE : float = 0.2

@onready var sprite_level : Sprite2D = $Level

var water_capacity : float = 0.0
var heated : float = 0.0
var temperature : float = 0.0

func get_heated() -> void:
	heated = 0.1

func _process(delta : float) -> void:
	if is_wet():
		water_capacity = clamp(water_capacity + (FILL_RATE * delta), 0.0, 1.0)
	
	if heated > 0.0:
		temperature = clamp(temperature + (HEAT_RATE * delta), 0.0, 1.0)
	else:
		temperature = clamp(temperature - (COOL_RATE * delta), 0.0, 1.0)
	heated = clamp(heated - delta, 0.0, 0.1)
	
	if temperature > 0.5:
		water_capacity = clamp(water_capacity - (BOIL_RATE * delta), 0.0, 1.0)
	
	sprite_level.modulate = lerp(Color("249fde"), Color("b4202a"), temperature)
	sprite_level.frame = water_capacity * 6.0
	mass = 1.0 + (water_capacity * 3.0)
