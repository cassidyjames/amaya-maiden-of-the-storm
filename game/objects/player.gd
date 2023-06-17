extends CharacterBody2D

class_name Player

const _SpriteParticles : PackedScene = preload("res://objects/sprite_particle.tscn")

const RUN_SPEED : float = 80.0
const RUN_ACCEL : float = 512.0
const RUN_DECEL : float = 512.0
const JUMP : float = 240.0
const FALL_INCR : float = 280.0
const MAX_FALL : float = 160.0

@onready var sprite : Sprite2D = $Sprite2D
@onready var orb_float_point : Node2D = $OrbFloatPoint
@onready var arrow_left : Sprite2D = $Arrow_Left
@onready var arrow_right : Sprite2D = $Arrow_Right
@onready var timer_spawn_death_spark : Timer = $Timer_SpawnDeathSpark
@onready var audio_footstep1 : AudioStreamPlayer = $Audio_Footstep1
@onready var audio_footstep2 : AudioStreamPlayer = $Audio_Footstep2
@onready var audio_jump : AudioStreamPlayer = $Audio_Jump
@onready var audio_land : AudioStreamPlayer = $Audio_Land

enum State {NORMAL, JUMPING, WIND_CHANGE, CHANGE_LEFT, CHANGE_RIGHT, HIT}

var current_state : int = State.NORMAL
var has_orb : bool = false

var anim_index : float = 0.0
var shine_a : float = 0.0
var shine_b : float = 0.0
var spawn_invuln : float = 0.1
var coyote_time : float = 0.0
var rundust_cooldown : float = 0.0
var which_footstep : bool = false

func get_hit_with_rain() -> void:
	if current_state == State.HIT or spawn_invuln > 0.0: return
	get_tree().call_group("orb", "_on_player_hit")
	current_state = State.HIT
	anim_index = 0.0
	timer_spawn_death_spark.start()
	var tween : Tween = create_tween().set_parallel()
	tween.tween_property(self, "shine_a", 1.0, 0.1)
	tween.tween_property(self, "shine_b", 0.5, 0.75)
	await tween.finished
	for i in range(0, 6):
		var sprite_particle : Sprite2D = _SpriteParticles.instantiate()
		get_parent().add_child(sprite_particle)
		sprite_particle.setup("deathorb")
		sprite_particle.global_position = global_position + Vector2(0, -15)
		sprite_particle.velocity = Vector2.UP.rotated((i*PI)/3.0) * 256.0
	get_tree().call_group("game", "_on_player_dead")
	queue_free()

func do_horizontal_movement(delta : float) -> void:
	var collision : KinematicCollision2D = move_and_collide(velocity * Vector2(1.0, 0.0) * delta)
	if collision != null:
		var normal : Vector2 = collision.get_normal().snapped(Vector2(0.25, 0.25))
		if normal in [Vector2.LEFT, Vector2.RIGHT]:
			if collision.get_collider().is_in_group("wet_push_thing") and current_state == State.NORMAL:
				collision.get_collider().get_pushed(normal * Vector2(-1, 0), delta)
				sprite.frame = wrapi(anim_index, 20, 28)
			else:
				velocity.x = 0.0

func do_vertical_movement(delta : float) -> void:
	var collision : KinematicCollision2D = move_and_collide(velocity * Vector2(0.0, 1.0) * delta)
	if collision != null:
		var normal : Vector2 = collision.get_normal().snapped(Vector2(0.25, 0.25))
		if normal == Vector2.DOWN:
			velocity.y = 0.0
		elif normal == Vector2.UP and current_state == State.JUMPING:
			velocity.y = 0.0
			current_state = State.NORMAL
			anim_index = 0.0
			audio_land.play()

func do_the_run_thing(direction : Vector2, multiplier : float, flip_sprite : bool, delta : float) -> void:
	velocity.x = clamp(velocity.x + (direction.x * multiplier * RUN_ACCEL * delta), -RUN_SPEED, RUN_SPEED)
	sprite.flip_h = flip_sprite
	if current_state == State.NORMAL:
		sprite.frame = wrapi(anim_index, 10, 20)
		anim_index += delta * 10.0
		if (sprite.frame == 11 or sprite.frame == 16) and rundust_cooldown == 0.0:
			emit_run_particle()
			rundust_cooldown = 0.2

func shift_wind(direction : Vector2, state : int) -> void:
	get_tree().call_group("rainrow", "change_rain_direction", direction)
	get_tree().call_group("game", "_on_player_shift")
	sprite.flip_h = direction == Vector2.RIGHT
	anim_index = 0.0
	current_state = state
	arrow_left.hide()
	arrow_right.hide()

func emit_jump_particles() -> void:
	for direction in [Vector2.LEFT, Vector2.RIGHT]:
		var sprite_particle : Sprite2D = _SpriteParticles.instantiate()
		get_parent().add_child(sprite_particle)
		sprite_particle.setup("jumpdust")
		sprite_particle.global_position = global_position + Vector2(8 * direction.x, -6)
		sprite_particle.velocity = direction * 64.0
		sprite_particle.flip_h = direction == Vector2.LEFT

func emit_run_particle() -> void:
	var direction : Vector2 = Vector2.LEFT if sprite.flip_h else Vector2.RIGHT
	var sprite_particle : Sprite2D = _SpriteParticles.instantiate()
	get_parent().add_child(sprite_particle)
	sprite_particle.setup("rundust")
	sprite_particle.global_position = global_position + Vector2(-12.0 * direction.x, -6)
	sprite_particle.flip_h = sprite.flip_h
	if which_footstep:
		audio_footstep1.play()
	else:
		audio_footstep2.play()
	which_footstep = !which_footstep

func state_normal(delta : float) -> void:
	if Input.is_action_pressed("run_right"):
		do_the_run_thing(Vector2.RIGHT, 1.0, false, delta)
	elif Input.is_action_pressed("run_left"):
		do_the_run_thing(Vector2.LEFT, 1.0, true, delta)
	else:
		if Input.is_action_just_released("run_left") or Input.is_action_just_released("run_right"):
			anim_index = 0.0
		else:
			anim_index += delta
		velocity.x = move_toward(velocity.x, 0.0, RUN_DECEL * delta)
		if anim_index > 12.0:
			anim_index = 0.0
		elif anim_index > 8.0:
			sprite.frame = clampi((anim_index - 8.0) * 10.0, 5, 8)
		elif anim_index > 4.0:
			sprite.frame = clampi((anim_index - 4.0) * 10.0, 1, 4)
		else:
			sprite.frame = 0
	
	if !test_move(transform, Vector2.DOWN):
		current_state = State.JUMPING
		anim_index = 0.0
		coyote_time = 0.5
	else:
		if Input.is_action_just_pressed("jump"):
			velocity.y = -JUMP
			current_state = State.JUMPING
			anim_index = 0.0
			sprite.frame = 50
			emit_jump_particles()
			audio_jump.play()
		elif Input.is_action_just_pressed("change_wind"):
			current_state = State.WIND_CHANGE
			anim_index = 0.0
			arrow_left.show()
			arrow_right.show()
	
	do_horizontal_movement(delta)
	do_vertical_movement(delta)

func state_jumping(delta : float) -> void:
	if coyote_time <= 0.0:
		if velocity.y > 0.0:
			sprite.frame = 51 + clamp(anim_index, 0, 1)
			anim_index += delta * 10.0
		else:
			sprite.frame = 50
	
	if Input.is_action_pressed("run_right"):
		do_the_run_thing(Vector2.RIGHT, 0.5, false, delta)
	elif Input.is_action_pressed("run_left"):
		do_the_run_thing(Vector2.LEFT, 0.5, true, delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, RUN_DECEL * delta)
	
	if coyote_time > 0.0 and Input.is_action_just_pressed("jump"):
		velocity.y = -JUMP
		current_state = State.JUMPING
		anim_index = 0.0
		audio_jump.play()
	else:
		if !Input.is_action_pressed("jump"):
			velocity.y = clamp(velocity.y + (FALL_INCR * delta), -MAX_FALL / 2.0, MAX_FALL)
		else:
			velocity.y = clamp(velocity.y + (FALL_INCR * delta), -MAX_FALL, MAX_FALL)
	
	coyote_time = clamp(coyote_time - delta, 0.0, 0.1)
	
	do_horizontal_movement(delta)
	do_vertical_movement(delta)

func state_wind_change(delta : float) -> void:
	anim_index += delta * 10.0
	sprite.frame = 30 + clampf(anim_index, 0.0, 1.0)
	arrow_left.offset.x = sin(anim_index) * 4.0
	arrow_right.offset.x = -sin(anim_index) * 4.0
	if Input.is_action_just_pressed("run_left"):
		shift_wind(Vector2.LEFT, State.CHANGE_LEFT)
	elif Input.is_action_just_pressed("run_right"):
		shift_wind(Vector2.RIGHT, State.CHANGE_RIGHT)
	elif Input.is_action_just_pressed("change_wind"):
		sprite.frame = 0
		anim_index = 0.0
		current_state = State.NORMAL
		arrow_left.hide()
		arrow_right.hide()

func state_change_left(delta : float) -> void:
	anim_index += delta
	sprite.frame = 32 + clamp(anim_index * 15.0, 0, 13)
	if anim_index > 2.0:
		sprite.flip_h = true
		sprite.frame = 0
		current_state = State.NORMAL

func state_change_right(delta : float) -> void:
	anim_index += delta
	sprite.frame = 32 + clamp(anim_index * 15.0, 0, 13)
	if anim_index > 2.0:
		sprite.flip_h = false
		sprite.frame = 0
		current_state = State.NORMAL

func _on_timer_spawn_death_spark_timeout() -> void:
	for direction in [Vector2.UP, Vector2.DOWN]:
		var sprite_particle : Sprite2D = _SpriteParticles.instantiate()
		get_parent().add_child(sprite_particle)
		sprite_particle.setup("deathspark")
		sprite_particle.global_position = global_position + Vector2(0, -15)
		sprite_particle.velocity = direction.rotated(anim_index) * 128.0
		anim_index += PI/6.0

func _physics_process(delta : float) -> void:
	match current_state:
		State.NORMAL: state_normal(delta)
		State.JUMPING: state_jumping(delta)
		State.WIND_CHANGE: state_wind_change(delta)
		State.CHANGE_LEFT: state_change_left(delta)
		State.CHANGE_RIGHT: state_change_right(delta)
	global_position.x = clampf(global_position.x, 0.0, 640.0)
	sprite.material.set_shader_parameter("shine_a", shine_a)
	sprite.material.set_shader_parameter("shine_b", shine_b)
	spawn_invuln = clamp(spawn_invuln - delta, 0.0, 0.1)
	rundust_cooldown = clamp(rundust_cooldown - delta, 0.0, 0.2)
