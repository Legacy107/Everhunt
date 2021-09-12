extends Reference


static func reparent(child, new_parent):
	var old_parent = child.get_parent()

	# Use call_deferred to avoid race conditions
	old_parent.call_deferred("remove_child", child)
	new_parent.call_deferred("add_child", child)
	child.call_deferred("set_owner", new_parent)


# Play animation from an AnimationPlayer or AnimatedSprite
static func play_animation(AnimationPlayer_, animation, replay=false):
	var current_animation = "current_animation" \
		if AnimationPlayer_ is AnimationPlayer \
		else "animation"

	if AnimationPlayer_.is_playing() and AnimationPlayer_[current_animation] == animation:
		if replay:
			AnimationPlayer_.stop()
		else:
			return

	AnimationPlayer_.play(animation)
