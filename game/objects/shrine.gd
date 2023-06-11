extends Area2D

signal got_orb

func _on_body_entered(body) -> void:
	if body is Player and body.has_orb:
		get_tree().call_group("game", "_on_level_clear")
