extends StaticBody2D

class_name TreeGarden

const GROWTH_RATE : float = 0.25

@onready var outline_l : Sprite2D = $Outline_L
@onready var sprite : Sprite2D = $Sprite2D
@onready var treetop : StaticBody2D = $StaticBody2D_Treetop

var growth : float = 0.0
var rained_on : float = 0.0
var fully_grown : bool = false

func hit_by_rain() -> void:
	rained_on = 0.1

func _process(delta):
	rained_on = clamp(rained_on - delta, 0.0, 0.1)
	if rained_on > 0.0 and not fully_grown:
		growth = clamp(growth + (GROWTH_RATE * delta), 0.0, 1.0)
		if growth >= 1.0:
			fully_grown = true
			treetop.show()
			treetop.set_collision_layer_value(1, true)
	sprite.material.set_shader_parameter("growth", growth)
	outline_l.material.set_shader_parameter("growth", growth)
