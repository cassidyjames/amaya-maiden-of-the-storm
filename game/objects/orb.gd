extends Area2D

const _SpriteParticles : PackedScene = preload("res://objects/sprite_particle.tscn")

const FOLLOW_SPEED : float = 3.0
const LAUNCH_SPEED : float = 128.0
const FALL_ACCEL : float = 512.0
const MAX_SPEED : float = 256.0

enum State {FLOATING, FOLLOWING, FALLING}

@onready var sprite : Sprite2D = $Sprite2D
@onready var audio_picked_up : AudioStreamPlayer = $Audio_PickedUp

var velocity : Vector2 = Vector2.ZERO
var current_state : int = State.FLOATING
var player : Node2D
var wobble_index : float = 0.0

func _on_body_entered(body) -> void:
	if body is Player and current_state == State.FLOATING:
		player = body
		body.has_orb = true
		current_state = State.FOLLOWING
		audio_picked_up.play()

func _on_timer_next_frame_timeout() -> void:
	sprite.frame = wrapi(sprite.frame + 1, 0, 18)
	var sprite_particle : Sprite2D = _SpriteParticles.instantiate()
	get_parent().add_child(sprite_particle)
	sprite_particle.setup("spark1" if randf() > 0.5 else "spark2")
	sprite_particle.global_position = global_position + Vector2(randf_range(-8.0, 8.0), randf_range(-8.0, 8.0))
	sprite_particle.velocity = Vector2.DOWN * randf_range(32.0, 96.0)

func _on_player_hit() -> void:
	if current_state != State.FOLLOWING: return
	velocity = Vector2.RIGHT.rotated(randf() * PI * 2.0) * LAUNCH_SPEED
	current_state = State.FALLING

func _physics_process(delta : float) -> void:
	wobble_index += delta
	if current_state == State.FOLLOWING:
		var target : Vector2 = player.orb_float_point.global_position
		target += Vector2(cos(wobble_index * 3.0) * 16.0, sin(wobble_index * 6.0) * 8.0)
		global_position = global_position.lerp(target, FOLLOW_SPEED * delta)
	elif current_state == State.FALLING:
		position += velocity * delta
		velocity += Vector2.DOWN * FALL_ACCEL * delta
		velocity = velocity.limit_length(MAX_SPEED)

