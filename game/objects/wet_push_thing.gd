extends StaticBody2D

class_name WetPushThing

const ZERO_MASS_PUSH_SPEED : float = 64.0
const PLAYER_MASS : float = 1.0
const FALL_INCR : float = 256.0
const MAX_FALL : float = 128.0

@export_node_path("Area2D") var path_area_top_space
@export var mass : float = 1.0
@export var attached : bool = false

@onready var area_top_space : Area2D = get_node(path_area_top_space)

var wetness : float = 0.0
var fall_speed : float = 0.0
var spawn_invuln : float = 0.1

func is_wet() -> bool:
	return wetness > 0.0 and spawn_invuln == 0.0

func hit_by_rain() -> void:
	wetness = 0.1

func get_things_in_area(area : Area2D) -> Array:
	var results : Array = []
	for body in area.get_overlapping_bodies():
		if (body.is_in_group("wet_push_thing") or body is Player) and body != self:
			results.append(body)
	return results

func get_mass_of_things(things : Array) -> float:
	var result : float = 0.0
	for thing in things:
		if thing.is_in_group("wet_push_thing"):
			result += thing.get_mass_of_self_and_top()
		else:
			result += PLAYER_MASS
	return result

func get_mass_of_self_and_top() -> float:
	return mass + get_mass_of_things(get_things_in_area(area_top_space))

func get_pushed(direction : Vector2, delta : float) -> float:
	if attached:
		return 0.0
	
	var things_to_be_pushed : Array = get_things_in_area(area_top_space)
	
	var total_mass : float = mass
	for thing in things_to_be_pushed:
		if thing.is_in_group("wet_push_thing"):
			total_mass += thing.get_mass_of_self_and_top()
	
	var distance_to_move : float = remap(total_mass, 0.0, 4.0, ZERO_MASS_PUSH_SPEED, 0.0)
	distance_to_move = clamp(distance_to_move, 0.0, ZERO_MASS_PUSH_SPEED)
	distance_to_move *= delta
	
	var collision : KinematicCollision2D = move_and_collide(distance_to_move * direction)
	var distance_moved : float = distance_to_move
	if collision != null:
		distance_moved -= collision.get_remainder().length()
	
	for thing in things_to_be_pushed:
		thing.move_and_collide(distance_moved * direction)
	
	return distance_moved

func descend(distance : float) -> float:
	var collision : KinematicCollision2D = move_and_collide(Vector2.DOWN * distance)
	var remainder : float = 0.0
	if collision != null:
		remainder = collision.get_remainder().length()
	var distance_moved = distance - remainder
	if distance_moved > 0.0:
		for thing in get_things_in_area(area_top_space):
			if thing is Player and thing.can_be_moved():
				thing.move_and_collide(Vector2.DOWN * distance_moved)
			else:
				thing.move_and_collide(Vector2.DOWN * distance_moved)
	
	return remainder

func _physics_process(delta : float) -> void:
	spawn_invuln = clamp(spawn_invuln - delta, 0.0, 0.1)
	wetness = clamp(wetness - delta, 0.0, 0.1)
	if not attached:
		if !test_move(transform, Vector2.DOWN):
			fall_speed = clamp(fall_speed + (FALL_INCR * delta), 0.0, FALL_INCR)
			move_and_collide(Vector2.DOWN * fall_speed * delta)
		else:
			fall_speed = 0.0
