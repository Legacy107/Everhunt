extends Area2D


var MAX_SPEED = 200


export var velocity = Vector2()


func setup(Origin, dir): 
	global_position = Origin.global_position
	velocity = dir * MAX_SPEED


func _physics_process(delta):
	position += velocity * delta


func _on_Bullet_body_entered(body):
	if body.is_in_group('terrain'):
		queue_free()
