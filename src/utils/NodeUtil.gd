extends Object


func reparent(child, new_parent):
	var old_parent = child.get_parent()
	old_parent.call_deferred("remove_child", child)
	new_parent.call_deferred("add_child", child)
	child.call_deferred("set_owner", new_parent)


func play_animation(AnimationPlayer, animation):
	if AnimationPlayer.is_playing() and AnimationPlayer.current_animation == animation:
		return

	AnimationPlayer.play(animation)


func replay_animation(AnimationPlayer, animation):
	if AnimationPlayer.is_playing() and AnimationPlayer.current_animation == animation:
		AnimationPlayer.stop()

	AnimationPlayer.play(animation)
