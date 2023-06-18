extends StaticBody2D

class_name TreeGarden

const _SpriteParticles : PackedScene = preload("res://objects/sprite_particle.tscn")

const GROWTH_RATE : float = 0.25

@onready var outline_l : Sprite2D = $Outline_L
@onready var sprite : Sprite2D = $Sprite2D
@onready var treetop : StaticBody2D = $StaticBody2D_Treetop
@onready var audio_growing : AudioStreamPlayer = $Audio_Growing
@onready var audio_grown : AudioStreamPlayer = $Audio_Grown

var growth : float = 0.0
var rained_on : float = 0.0
var fully_grown : bool = false

func hit_by_rain() -> void:
	rained_on = 0.1

func emit_tree_particles() -> void:
	for i in range(0, 10):
		var sprite_particle : Sprite2D = _SpriteParticles.instantiate()
		get_parent().add_child(sprite_particle)
		sprite_particle.setup("leaf1")
		sprite_particle.global_position = global_position + Vector2(randf_range(-32.0, 32.0), randf_range(-56.0, -40.0))
		sprite_particle.velocity = Vector2.DOWN.rotated(randf_range(-0.5, 0.5)) * randf_range(16.0, 32.0)
		sprite_particle.override_speed(randf_range(0.1, 0.3))
		sprite_particle.z_index = -20
	for i in range(0, 10):
		var sprite_particle : Sprite2D = _SpriteParticles.instantiate()
		get_parent().add_child(sprite_particle)
		sprite_particle.setup("acorn1")
		sprite_particle.global_position = global_position + Vector2(randf_range(-32.0, 32.0), randf_range(-56.0, -40.0))
		sprite_particle.velocity = Vector2.DOWN.rotated(randf_range(-0.5, 0.5)) * randf_range(64.0, 96.0)
		sprite_particle.z_index = 100

func _process(delta):
	rained_on = clamp(rained_on - delta, 0.0, 0.1)
	if rained_on > 0.0 and not fully_grown:
		if growth == 0.0:
			audio_growing.play()
		growth = clamp(growth + (GROWTH_RATE * delta), 0.0, 1.0)
		if growth >= 1.0:
			fully_grown = true
			treetop.show()
			treetop.set_collision_layer_value(1, true)
			treetop.set_collision_layer_value(2, true)
			emit_tree_particles()
			audio_grown.play()
	sprite.material.set_shader_parameter("growth", growth)
	outline_l.material.set_shader_parameter("growth", growth)
