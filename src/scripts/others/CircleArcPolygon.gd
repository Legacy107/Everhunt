extends Node2D
# Original source: https://docs.godotengine.org/en/stable/tutorials/2d/custom_drawing_in_2d.html


export var center = Vector2(0, 0)
export var radius = 0
export var angle_from = 0
export var angle_to = 0
export var color = Color(0, 0, 0)
export var number_points = 32


func _draw():
	draw_circle_arc_poly(center, radius, angle_from, angle_to, color)


func draw_circle_arc_poly(center_, radius_, angle_from_, angle_to_, color_):
	var points_arc = PoolVector2Array()
	points_arc.push_back(center_)
	var colors = PoolColorArray([color_])

	for i in range(number_points + 1):
		var angle_point = deg2rad(
			angle_from_ + i * (angle_to_ - angle_from_) / number_points - 90
		)
		points_arc.push_back(
			center_ + Vector2(cos(angle_point), sin(angle_point)) * radius_
		)
	draw_polygon(points_arc, colors)
