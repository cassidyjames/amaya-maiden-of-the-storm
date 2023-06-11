extends Sprite2D

var velocity : Vector2 = Vector2.ZERO

func _on_timer_next_frame_timeout() -> void:
	if frame == 6:
		queue_free()
	else:
		frame += 1

func _physics_process(delta : float) -> void:
	position += velocity * delta
