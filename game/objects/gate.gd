extends StaticBody2D

func get_mass() -> float:
	return 3.0

func descend(distance : float) -> float:
	var collision : KinematicCollision2D = move_and_collide(Vector2.DOWN * distance)
	if collision == null:
		return 0.0
	else:
		return collision.get_remainder().length()
