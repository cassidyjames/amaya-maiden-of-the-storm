extends Sprite2D

func _on_timer_next_frame_timeout() -> void:
	if frame == 2:
		queue_free()
	else:
		frame += 1
