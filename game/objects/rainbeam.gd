extends RayCast2D

const _Rainsplash : PackedScene = preload("res://objects/rainsplash.tscn")

@onready var sprite = $Sprite

var fall_speed : float = randf_range(16.0, 32.0)
var rain_refresh : float = randf_range(0.5, 1.5)

func _process(delta : float) -> void:
	sprite.region_rect.position.y -= fall_speed * delta
	if is_colliding():
		var beam_length : float = (get_collision_point() - global_position).length()
		sprite.region_rect.size.y = beam_length / 8.0
		if get_collider() is Player:
			get_collider().get_hit_with_rain()
		elif rain_refresh <= 0.0 and get_collision_normal() == Vector2.UP and get_collision_point().y > 32.0:
			var rainsplash : Sprite2D = _Rainsplash.instantiate()
			get_parent().add_child(rainsplash)
			rainsplash.global_position = get_collision_point()
			rain_refresh = randf_range(0.5, 1.0)
		elif (get_collider() is Bucket or get_collider() is Torch or get_collider() is TreeGarden) and get_collision_normal() == Vector2.UP:
			get_collider().hit_by_rain()
	else:
		sprite.region_rect.size.y = 90.0
	rain_refresh -= delta

func _ready() -> void:
	sprite.region_rect.position.y = randf_range(0.0, 90.0)
