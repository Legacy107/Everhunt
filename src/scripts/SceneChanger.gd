extends CanvasLayer


onready var AnimationPlayer_ = $AnimationPlayer


func change_scene(path, delay=0.5):
	yield(get_tree().create_timer(delay), "timeout")

	AnimationPlayer_.play("Fade")
	yield(AnimationPlayer_, "animation_finished")

	assert(get_tree().change_scene(path) == OK)

	AnimationPlayer_.play_backwards("Fade")
	yield(AnimationPlayer_, "animation_finished")
