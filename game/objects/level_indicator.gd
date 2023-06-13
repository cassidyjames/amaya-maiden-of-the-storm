extends Node2D

const ORB_COUNT : int = 6
const ORB_OFFSET : float = (PI * 2) / ORB_COUNT

@onready var orb : Sprite2D = $Orb
@onready var orbs : Array = [orb]

var orb_rotation : float = 0.0
var orb_radius : float = 380.0

func play(orbs_lit : int) -> void:
	for i in range(0, ORB_COUNT):
		orbs[i].modulate = Color.WHITE if i < orbs_lit else Color.DARK_GRAY
			
	var tween : Tween = create_tween()
	tween.tween_property(self, "orb_radius", 60.0, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_interval(1.0)
	tween.tween_property(self, "orb_radius", 380.0, 1.0).set_trans(Tween.TRANS_CUBIC)

func _physics_process(delta : float) -> void:
	orb_rotation += delta * 2.0
	for i in range(0, ORB_COUNT):
		orbs[i].position = Vector2(orb_radius, 0.0).rotated(orb_rotation + (ORB_OFFSET * i))

func _ready() -> void:
	for i in range(1, ORB_COUNT):
		var new_orb = orb.duplicate()
		orbs.append(new_orb)
		add_child(new_orb)
