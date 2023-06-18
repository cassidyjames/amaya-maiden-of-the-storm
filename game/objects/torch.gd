extends WetPushThing

class_name Torch

const _SpriteParticles : PackedScene = preload("res://objects/sprite_particle.tscn")

const HEALTH_DECR : float = 0.65

@onready var sprite : Sprite2D = $Sprite2D
@onready var flame : Sprite2D = $Flame
@onready var area_flame : Area2D = $Area2D_Flame
@onready var audio_douse : AudioStreamPlayer = $Audio_Douse
@onready var audio_fire : AudioStreamPlayer = $Audio_Fire

var health : float = 1.0

func _on_area_2d_flame_body_entered(body) -> void:
	if body is Player and health > 0.1:
		body.get_hit_with_rain()

func _on_timer_emit_particle_timeout() -> void:
	if is_wet() and health > 0.0:
		var sprite_particle : Sprite2D = _SpriteParticles.instantiate()
		get_parent().add_child(sprite_particle)
		sprite_particle.setup("steam1" if randf() > 0.5 else "steam2")
		sprite_particle.global_position = global_position + Vector2(randf_range(-8.0, 8.0), 0.0)
		sprite_particle.velocity = Vector2.UP.rotated(randf_range(-0.1, 0.1)) * randf_range(32.0, 96.0)
		sprite_particle.z_index = -20
		if health > 0.5 and !audio_douse.playing:
			audio_douse.play()
	if health > 0.5:
		var sprite_particle : Sprite2D = _SpriteParticles.instantiate()
		get_parent().add_child(sprite_particle)
		sprite_particle.setup("ember1" if randf() > 0.5 else "ember2")
		sprite_particle.global_position = global_position + Vector2(randf_range(-8.0, 8.0), 0.0)
		sprite_particle.velocity = Vector2.UP * randf_range(32.0, 96.0)
		sprite_particle.z_index = -20

# Horrific janky fix
func _on_timer_jiggle_flame_timeout() -> void:
	area_flame.position.x = randf_range(-0.1, 0.1)

func _process(delta : float) -> void:
	if is_wet():
		health = clamp(health - (HEALTH_DECR * delta), 0.0, 1.0)
		sprite.frame = health * 4
		flame.material.set_shader_parameter("multiplier", health)
		audio_fire.volume_db = remap(health, 0.0, 1.0, -40.0, 0.0)
		if health <= 0.1:
			audio_fire.stop()
	for body in area_flame.get_overlapping_bodies():
		if body is Bucket:
			body.get_heated()

func _ready() -> void:
	flame.material = flame.material.duplicate(true)
	audio_douse.pitch_scale = randf_range(0.5, 1.0)
	audio_fire.pitch_scale = randf_range(0.75, 1.25)
	audio_fire.play()
