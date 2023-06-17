extends Node2D

const _SpriteParticles : PackedScene = preload("res://objects/sprite_particle.tscn")

const ORB_COUNT : int = 8
const ORB_OFFSET : float = (PI * 2) / ORB_COUNT

@onready var orb : Sprite2D = $Orb
@onready var orbs : Array = [orb]
@onready var audio_all_clear : AudioStreamPlayer = $Audio_AllClear
@onready var whiteout : Polygon2D = $Whiteout

var orb_rotation : float = 0.0
var orb_radius : float = 380.0
var orb_raise : float = 0.0

func play(orbs_lit : int) -> void:
	for i in range(0, ORB_COUNT):
		orbs[i].modulate = Color.WHITE if i < orbs_lit else Color(0.2, 0.3, 0.3)
		orbs[i].frame = i*2
	var tween : Tween = create_tween()
	tween.tween_property(self, "orb_radius", 60.0, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_interval(1.0)
	tween.tween_property(self, "orb_radius", 380.0, 1.0).set_trans(Tween.TRANS_CUBIC)

func play_ending() -> void:
	for i in range(0, ORB_COUNT):
		orbs[i].modulate = Color.WHITE
		orbs[i].frame = i*2
	audio_all_clear.play()
	var tween : Tween = create_tween()
	tween.tween_property(self, "orb_radius", 60.0, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_interval(4.0)
	tween.tween_property(self, "orb_raise", 8.0, 12.0).set_trans(Tween.TRANS_LINEAR)
	tween.tween_interval(1.0)
	tween.tween_property(whiteout, "modulate", Color.WHITE, 1.0).set_trans(Tween.TRANS_LINEAR)

func _physics_process(delta : float) -> void:
	orb_rotation += delta * 2.0
	for i in range(0, ORB_COUNT):
		orbs[i].position = Vector2(orb_radius, 0.0).rotated(orb_rotation + (ORB_OFFSET * i))
		var raise : float = clamp(orb_raise - i, 0.0, 1.0)
		raise *= raise
		orbs[i].position.y -= raise * 260.0

func _ready() -> void:
	for i in range(1, ORB_COUNT):
		var new_orb = orb.duplicate()
		orbs.append(new_orb)
		add_child(new_orb)


func _on_timer_next_frame_timeout() -> void:
	for i in range(0, ORB_COUNT):
		orbs[i].frame = wrapi(orbs[i].frame + 1, 0, 18)
		if orbs[i].modulate == Color.WHITE:
			var sprite_particle : Sprite2D = _SpriteParticles.instantiate()
			add_child(sprite_particle)
			sprite_particle.setup("spark1" if randf() > 0.5 else "spark2")
			sprite_particle.global_position = orbs[i].global_position + Vector2(randf_range(-8.0, 8.0), randf_range(-8.0, 8.0))
			sprite_particle.velocity = Vector2.DOWN * randf_range(32.0, 96.0)
