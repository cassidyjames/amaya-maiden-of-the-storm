extends Node2D

const _Rainbeam : PackedScene = preload("res://objects/rainbeam.tscn")

const RAIN_BOX : Rect2 = Rect2(-200.0, 0.0, 1040.0, 0.0)
const RAIN_GAP : float = 6.0

var rainbeams : Array = []
var current_direction : Vector2 = Vector2.ZERO

func change_rain_angle(angle : float) -> void:
	var tween : Tween = create_tween()
	tween.set_parallel()
	for rainbeam in rainbeams:
		tween.tween_property(rainbeam, "rotation_degrees", angle, 2.0)

func change_rain_direction(direction : Vector2) -> void:
	current_direction += direction
	current_direction.x = clamp(current_direction.x, -1.0, 1.0)
	match current_direction:
		Vector2.LEFT: change_rain_angle(30.0)
		Vector2.ZERO: change_rain_angle(0.0)
		Vector2.RIGHT: change_rain_angle(-30.0)

func _ready() -> void:
	for x in range(RAIN_BOX.position.x, RAIN_BOX.end.x, RAIN_GAP):
		var rainbeam : Node2D = _Rainbeam.instantiate()
		rainbeam.global_position = Vector2(x, RAIN_BOX.position.y)
		add_child(rainbeam)
		rainbeams.append(rainbeam)
