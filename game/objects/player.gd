extends CharacterBody2D

class_name Player

const _SpriteParticles : PackedScene = preload("res://objects/sprite_particle.tscn")

const RUN_SPEED : float = 80.0
const RUN_ACCEL : float = 512.0
const RUN_DECEL : float = 512.0
const JUMP : float = 160.0
const FALL_INCR : float = 240.0
const MAX_FALL : float = 320.0

@onready var sprite : Sprite2D = $Sprite2D
@onready var orb_float_point : Node2D = $OrbFloatPoint
@onready var arrow_left : Sprite2D = $Arrow_Left
@onready var arrow_right : Sprite2D = $Arrow_Right
@onready var timer_spawn_death_spark : Timer = $Timer_SpawnDeathSpark
@onready var audio_footstep1 : AudioStreamPlayer = $Audio_Footstep1
@onready var audio_footstep2 : AudioStreamPlayer = $Audio_Footstep2
@onready var audio_jump : AudioStreamPlayer = $Audio_Jump
@onready var audio_land : AudioStreamPlayer = $Audio_Land
@onready var audio_change_wind : AudioStreamPlayer = $Audio_ChangeWind

enum State {NORMAL, JUMPING, LANDING, WIND_CHANGE, CHANGE_LEFT, CHANGE_RIGHT, HIT}

var current_state : int = State.NORMAL
var has_orb : bool = false

var anim_index : float = 0.0
var shine_a : float = 0.0
var shine_b : float = 0.0
var spawn_invuln : float = 0.1
var coyote_time : float = 0.0
var rundust_cooldown : float = 0.0
var which_footstep : bool = false
var shifted_wind : bool = false

func can_be_moved() -> bool:
	if current_state == State.JUMPING or current_state == State.HIT:
		return false
	return true

func get_hit_with_rain() -> void:
	if current_state == State.HIT or spawn_invuln > 0.0: return
	get_tree().call_group("orb", "_on_player_hit")
	AudioController.play_player_die()
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
		elif normal == Vector2(-0.75, -0.75):
			move_and_collide(Vector2(1, -1).normalized() * collision.get_remainder().length())
		elif normal == Vector2(0.75, -0.75):
			move_and_collide(Vector2(-1, -1).normalized() * collision.get_remainder().length())

func do_vertical_movement(delta : float) -> void:
	var collision : KinematicCollision2D = move_and_collide(velocity * Vector2(0.0, 1.0) * delta)
	if collision != null:
		var normal : Vector2 = collision.get_normal().snapped(Vector2(0.25, 0.25))
		if normal == Vector2.DOWN or normal.y == -0.75:
			velocity.y = 0.0
		elif normal == Vector2.UP and current_state == State.JUMPING:
			if velocity.y >= 200:
				current_state = State.LANDING
			else:
				current_state = State.NORMAL
			velocity.y = 0.0
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
	get_tree().call_group("game", "_on_player_shift")
	sprite.flip_h = direction == Vector2.RIGHT
	anim_index = 0.0
	current_state = state
	shifted_wind = false
	arrow_left.hide()
	arrow_right.hide()
	audio_change_wind.play()

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
	
	if Input.is_action_just_pressed("restart_level"):
		get_hit_with_rain()
	
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
			velocity.y = clamp(velocity.y + (FALL_INCR * delta), -MAX_FALL / 4.0, MAX_FALL)
		else:
			velocity.y = clamp(velocity.y + (FALL_INCR * delta), -MAX_FALL, MAX_FALL)
	
	coyote_time = clamp(coyote_time - delta, 0.0, 0.1)
	
	if Input.is_action_just_pressed("restart_level"):
		get_hit_with_rain()
	
	do_horizontal_movement(delta)
	do_vertical_movement(delta)

func state_landing(delta : float) -> void:
	anim_index += delta * 10.0
	if anim_index >= 4.0:
		current_state = State.NORMAL
		anim_index = 0.0
	else:
		sprite.frame = 53 + clamp(anim_index, 0.0, 2.0)
	
	if Input.is_action_just_pressed("restart_level"):
		get_hit_with_rain()

func state_praying(delta : float) -> void:
	anim_index += delta * 10.0
	sprite.frame = 30 + clampf(anim_index, 0.0, 1.0)
	arrow_left.offset.x = sin(anim_index) * 4.0
	arrow_right.offset.x = -sin(anim_index) * 4.0
	arrow_left.frame = wrapi(anim_index, 0, 18)
	arrow_right.frame = wrapi(anim_index, 0, 18)
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
	
	if Input.is_action_just_pressed("restart_level"):
		get_hit_with_rain()

func state_changing_wind(flip : bool, direction : Vector2, delta : float) -> void:
	anim_index += delta
	sprite.frame = 32 + clamp(anim_index * 15.0, 0, 15)
	if anim_index >= 1.0 and !shifted_wind:
		get_tree().call_group("rainrow", "change_rain_direction", direction)
		shifted_wind = true
	if anim_index > 2.0:
		sprite.flip_h = flip
		sprite.frame = 0
		current_state = State.NORMAL
	
	if Input.is_action_just_pressed("restart_level"):
		get_hit_with_rain()

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
		State.LANDING: state_landing(delta)
		State.JUMPING: state_jumping(delta)
		State.WIND_CHANGE: state_praying(delta)
		State.CHANGE_LEFT: state_changing_wind(true, Vector2.LEFT, delta)
		State.CHANGE_RIGHT: state_changing_wind(false, Vector2.RIGHT, delta)
	global_position.x = clampf(global_position.x, 0.0, 640.0)
	sprite.material.set_shader_parameter("shine_a", shine_a)
	sprite.material.set_shader_parameter("shine_b", shine_b)
	spawn_invuln = clamp(spawn_invuln - delta, 0.0, 0.1)
	rundust_cooldown = clamp(rundust_cooldown - delta, 0.0, 0.2)
