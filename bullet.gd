extends Area2D

var speed = 150
var direction = Vector2()

func _physics_process(delta):
	position += direction * speed * delta

func _on_Bullet_body_entered(body):
	if body.is_in_group('terrain'):
		queue_free()
