extends Area2D

var speed = 150
var direction = Vector2()

func setup(Origin, dir):
	transform = Origin.global_transform
	direction = dir

func _physics_process(delta):
	position += direction * speed * delta

func _on_Bullet_body_entered(body):
	if body.is_in_group('terrain'):
		queue_free()
