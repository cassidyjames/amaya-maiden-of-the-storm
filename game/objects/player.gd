extends CharacterBody2D

class_name Player

const _EnergyOrb : PackedScene = preload("res://objects/energy_orb.tscn")

const RUN_SPEED : float = 64.0
const RUN_ACCEL : float = 512.0
const RUN_DECEL : float = 512.0
const JUMP : float = 160.0
const FALL_INCR : float = 420.0
const MAX_FALL : float = 160.0

@onready var sprite : Sprite2D = $Sprite2D
@onready var orb_float_point : Node2D = $OrbFloatPoint
@onready var arrow_left : Sprite2D = $Arrow_Left
@onready var arrow_right : Sprite2D = $Arrow_Right

enum State {NORMAL, WIND_CHANGE, CHANGE_LEFT, CHANGE_RIGHT, HIT}

var current_state : int = State.NORMAL
var has_orb : bool = false

var anim_index : float = 0.0
var shine_a : float = 0.0
var shine_b : float = 0.0
var spawn_invuln : float = 0.1

func get_hit_with_rain() -> void:
	if current_state == State.HIT or spawn_invuln > 0.0: return
	get_tree().call_group("orb", "_on_player_hit")
	current_state = State.HIT
	var tween : Tween = create_tween().set_parallel()
	tween.tween_property(self, "shine_a", 1.0, 0.1)
	tween.tween_property(self, "shine_b", 0.5, 0.75)
	await tween.finished
	for direction in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		var orb : Sprite2D = _EnergyOrb.instantiate()
		get_parent().add_child(orb)
		orb.global_position = global_position + Vector2(0, -20)
		orb.velocity = direction * 100.0
	get_tree().call_group("game", "_on_player_dead")
	queue_free()

func do_the_move_thing(direction : Vector2, delta : float) -> void:
	var collision : KinematicCollision2D = move_and_collide(velocity * delta)
	if collision != null:
		var normal : Vector2 = collision.get_normal().snapped(Vector2(0.25, 0.25))
		if normal in [Vector2.UP, Vector2.DOWN]:
			velocity.y = 0.0
		elif normal in [Vector2.LEFT, Vector2.RIGHT]:
			velocity.x = 0.0

func state_normal(delta : float) -> void:
	if Input.is_action_pressed("run_right"):
		velocity.x = clamp(velocity.x + (RUN_ACCEL * delta), -RUN_SPEED, RUN_SPEED)
		sprite.flip_h = false
		sprite.frame = wrapi(anim_index, 12, 22)
		anim_index += delta * 20.0
	elif Input.is_action_pressed("run_left"):
		velocity.x = clamp(velocity.x - (RUN_ACCEL * delta), -RUN_SPEED, RUN_SPEED)
		sprite.flip_h = true
		sprite.frame = wrapi(anim_index, 12, 22)
		anim_index += delta * 20.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, RUN_DECEL * delta)
		sprite.frame = 0
		anim_index = 0.0
	
	if !test_move(transform, Vector2.DOWN):
		velocity.y = clamp(velocity.y + (FALL_INCR * delta), -MAX_FALL, MAX_FALL)
	else:
		if Input.is_action_just_pressed("jump"):
			velocity.y = -JUMP
		if Input.is_action_just_pressed("change_wind"):
			current_state = State.WIND_CHANGE
			anim_index = 0.0
			arrow_left.show()
			arrow_right.show()
	
	do_the_move_thing(Vector2.RIGHT, delta)
	do_the_move_thing(Vector2.DOWN, delta)
	global_position.x = clampf(global_position.x, 0.0, 640.0)

func state_wind_change(delta : float) -> void:
	anim_index += delta * 10.0
	sprite.frame = 1 + clampf(anim_index, 0.0, 1.0)
	arrow_left.offset.x = sin(anim_index) * 4.0
	arrow_right.offset.x = -sin(anim_index) * 4.0
	if Input.is_action_just_pressed("run_left"):
		get_tree().call_group("rainrow", "change_rain_direction", Vector2.LEFT)
		sprite.flip_h = false
		anim_index = 0.0
		current_state = State.CHANGE_LEFT
		arrow_left.hide()
		arrow_right.hide()
	elif Input.is_action_just_pressed("run_right"):
		get_tree().call_group("rainrow", "change_rain_direction", Vector2.RIGHT)
		sprite.flip_h = false
		anim_index = 0.0
		current_state = State.CHANGE_RIGHT
		arrow_left.hide()
		arrow_right.hide()
	elif Input.is_action_just_pressed("change_wind"):
		sprite.frame = 0
		anim_index = 0.0
		current_state = State.NORMAL
		arrow_left.hide()
		arrow_right.hide()

func state_change_left(delta : float) -> void:
	anim_index += delta * 10.0
	sprite.frame = 3 + clampf(anim_index, 0.0, 1.0)
	if anim_index > 20.0:
		sprite.flip_h = true
		sprite.frame = 0
		current_state = State.NORMAL

func state_change_right(delta : float) -> void:
	anim_index += delta * 10.0
	sprite.frame = 5 + clampf(anim_index, 0.0, 1.0)
	if anim_index > 20.0:
		sprite.flip_h = false
		sprite.frame = 0
		current_state = State.NORMAL

func _physics_process(delta : float) -> void:
	match current_state:
		State.NORMAL: state_normal(delta)
		State.WIND_CHANGE: state_wind_change(delta)
		State.CHANGE_LEFT: state_change_left(delta)
		State.CHANGE_RIGHT: state_change_right(delta)
	sprite.material.set_shader_parameter("shine_a", shine_a)
	sprite.material.set_shader_parameter("shine_b", shine_b)
	spawn_invuln = clamp(spawn_invuln - delta, 0.0, 0.1)
