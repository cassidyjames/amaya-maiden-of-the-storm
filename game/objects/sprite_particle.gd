extends Sprite2D

const PARTICLE_TYPES : Dictionary = {
	"spiral1": [0, 7, 0.1, -1, false],
	"spiral2": [8, 15, 0.1, -1, false],
	"steam1": [16, 23, 0.1, -1, false],
	"steam2": [24, 31, 0.1, -1, false],
	"spark1": [32, 35, 0.05, -1, false],
	"spark2": [40, 43, 0.05, -1, false],
	"deathspark": [80, 87, 0.05, -1, false],
	"jumpdust": [64, 68, 0.05, -1, false],
	"rundust": [72, 75, 0.1, -1, false],
	"deathorb": [48, 54, 0.05, -1, false],
	"ember1": [88, 95, 0.1, -1, false],
	"ember2": [96, 103, 0.2, -1, false],
}

@onready var timer_nextframe : Timer = $Timer_NextFrame

var kill_frame : int # Particle will die after passing this frame
var loop_frame : int # If looping, particle will return to this frame
var loop : bool # If true, particle will loop instead of dying after passing killframe
var velocity : Vector2 = Vector2.ZERO

func setup(particle_name : String) -> void:
	assert(PARTICLE_TYPES.has(particle_name))
	frame = PARTICLE_TYPES[particle_name][0]
	kill_frame = PARTICLE_TYPES[particle_name][1]
	loop_frame = PARTICLE_TYPES[particle_name][2]
	loop = PARTICLE_TYPES[particle_name][4]
	timer_nextframe.wait_time = PARTICLE_TYPES[particle_name][2]

func _on_timer_next_frame_timeout() -> void:
	if frame == kill_frame:
		if loop:
			frame = loop_frame
		else:
			queue_free()
	else:
		frame += 1

func _on_timer_timeout_timeout() -> void:
	queue_free()

func _physics_process(delta : float) -> void:
	position += velocity * delta
