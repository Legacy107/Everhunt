extends Line2D

var LENGTH = 50

func update_trajectory(origin, direction):
	clear_points()
	add_point(origin)
	add_point(origin + direction * LENGTH)

func toggle():
	if visible:
		hide()
	else:
		show()
