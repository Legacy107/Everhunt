extends Particles2D


func _on_body_entered(_body):
	if not emitting:
		restart()
