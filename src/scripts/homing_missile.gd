extends Area2D

var max_speed = 170
var max_force = 100
var acceleration = Vector2()
export var velocity = Vector2()

func setup(Origin, _direction): 
	global_position = Origin.global_position
	velocity = global_position.direction_to(get_global_mouse_position()) * max_speed

func apply_force(force):
	acceleration += force

func _physics_process(delta):
	var desired = global_position.direction_to(get_global_mouse_position()) * max_speed
	var force = velocity.direction_to(desired).clamped(max_force)
	apply_force(force)
	velocity = (velocity + acceleration).clamped(max_speed)
	position += velocity * delta

func _on_Bullet_body_entered(body):
	if body.is_in_group('terrain'):
		queue_free()
