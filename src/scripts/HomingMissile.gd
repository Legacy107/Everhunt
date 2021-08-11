extends Area2D


var MAX_SPEED = 150
var MAX_FORCE = 100


onready var Mouse = get_parent().get_node("Mouse")


var acceleration = Vector2()
export var velocity = Vector2()


func setup(Origin, dir): 
	global_position = Origin.global_position
	velocity = dir * MAX_SPEED


func apply_force(force):
	acceleration += force


func _physics_process(delta):
	var desired = global_position.direction_to(Mouse.position) * MAX_SPEED
	var force = velocity.direction_to(desired).clamped(MAX_FORCE)
	
	apply_force(force)
	velocity = (velocity + acceleration).clamped(MAX_SPEED)
	position += velocity * delta


func _on_Bullet_body_entered(body):
	if body.is_in_group('terrain'):
		queue_free()
