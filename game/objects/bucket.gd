extends WetPushThing

class_name Bucket

const _SpriteParticles : PackedScene = preload("res://objects/sprite_particle.tscn")

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

func _on_timer_emit_spiral_timeout() -> void:
	if temperature > 0.5 and water_capacity > 0.0:
		var sprite_particle : Sprite2D = _SpriteParticles.instantiate()
		get_parent().add_child(sprite_particle)
		sprite_particle.setup("spiral1" if randf() > 0.5 else "spiral2")
		sprite_particle.global_position = global_position + Vector2(randf_range(-8.0, 8.0), 16.0)
		sprite_particle.velocity = Vector2.UP * randf_range(16.0, 64.0)
		sprite_particle.z_index = -20

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
