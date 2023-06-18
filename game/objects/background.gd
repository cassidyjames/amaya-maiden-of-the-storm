extends Node2D

@onready var cloud1 : Sprite2D = $Cloud1
@onready var cloud2 : Sprite2D = $Cloud2
@onready var cloud3 : Sprite2D = $Cloud3
@onready var cloud_top1 : Sprite2D = $CloudTop1
@onready var cloud_top2 : Sprite2D = $CloudTop2
@onready var cloud_top3 : Sprite2D = $CloudTop3

var velocity : float = 0.0

func change_velocity(new_velocity : float) -> void:
	velocity = new_velocity * 2.0
	create_tween().tween_property(self, "velocity", new_velocity, 3.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)

func _process(delta : float) -> void:
	cloud1.region_rect.position.x -= velocity * 5.0 * delta
	cloud2.region_rect.position.x -= (velocity - 0.25) * 10.0 * delta
	cloud3.region_rect.position.x -= (velocity + 0.25) * 20.0 * delta
	cloud_top1.region_rect.position.x -= (velocity - 0.25) * 15.0 * delta
	cloud_top2.region_rect.position.x -= (velocity + 0.25) * 10.0 * delta
	cloud_top3.region_rect.position.x -= velocity * 5.0 * delta
