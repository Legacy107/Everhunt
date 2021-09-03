extends Object


func calculate_pivot_rotation(Pivot, Target, Origin):
	# This func calculates the Pivot rotation such that Origin's look vector points at
	# Target's global_position

	# Pivot is the pivot and the object whose rotation is calculated in this func
	# Origin must be a direct child of Pivot
	# Target is the target the Origin wants to point at

	# P = Pivot
	# T = Target
	# O = Origin
	# t = Projected Target

	# Origin is a direct child of Pivot
	var PO = Origin.position.length()
	var angle_OPx = Origin.position.angle()

	# Using the same frame of reference as Pivot
	var PT = (Pivot.get_parent().to_local(Target.global_position) \
		- Pivot.position).length()
	var angle_TPx = (Pivot.get_parent().to_local(Target.global_position) \
		- Pivot.position).angle()

	PT = max(PT, PO) # Making sure a root exists

	var angle_OPT = angle_OPx - angle_TPx

	var angle_POt = PI - angle_OPx
	var angle_OtP = asin(sin(angle_POt) / PT * PO) # Law of sine
	var angle_OPt = PI - angle_POt - angle_OtP

	return -(angle_OPT - angle_OPt) # Clockwise rotation
