extends Line2D

onready var Hand = $"../Hand"
var length = 50

func update_trajectory(delta):
	var direction = (get_local_mouse_position() - Hand.position).normalized() * length
	clear_points()
	add_point(Hand.position)
	add_point(Hand.position + direction)

func toggle():
	if visible:
		hide()
	else:
		show()

func _process(delta):
	update_trajectory(delta)
