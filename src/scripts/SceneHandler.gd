extends CanvasLayer


signal scene_changed


onready var AnimationPlayer_ = $AnimationPlayer


func change_scene(path, delay=0.3):
	yield(get_tree().create_timer(delay), "timeout")

	AnimationPlayer_.play("Fade")
	yield(AnimationPlayer_, "animation_finished")

	assert(get_tree().change_scene(path) == OK)
	emit_signal("scene_changed")

	AnimationPlayer_.play_backwards("Fade")
	yield(AnimationPlayer_, "animation_finished")
