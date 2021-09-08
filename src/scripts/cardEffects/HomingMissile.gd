extends Area2D


var MAX_SPEED = 150
var MAX_FORCE = 100


var acceleration = Vector2()
var velocity = Vector2()


onready var homing_missile_state = {
	"position" : position
}


func setup(origin, direction):
	global_position = origin
	velocity = direction * MAX_SPEED


func apply_force(force):
	acceleration += force


func _physics_process(delta):
	if not is_network_master():
		return

	var desired = global_position.direction_to(get_global_mouse_position()) * MAX_SPEED
	var force = velocity.direction_to(desired).clamped(MAX_FORCE)

	apply_force(force)
	velocity = (velocity + acceleration).clamped(MAX_SPEED)
	position += velocity * delta

	homing_missile_state["position"] = position

	ServerHandler.synchronize_unreliable(get_path(),
		"update_homing_missile_state", homing_missile_state
	)


func _on_body_entered(_body):
	ServerHandler.synchronize(get_path(),
		"queue_free_homing_missile", homing_missile_state
	)

	queue_free()




remote func update_homing_missile_state(state):
	if not is_network_master():
		position = state["position"]


remote func queue_free_homing_missile(_state):
	if not is_network_master():
		queue_free()
