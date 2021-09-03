extends Area2D


var MAX_SPEED = 200


var velocity = Vector2()


func setup(origin, direction):
	global_position = origin
	velocity = direction * MAX_SPEED


func _physics_process(delta):
	position += velocity * delta


func _on_body_entered(_body):
	queue_free()
