extends RigidBody2D

class_name CTFFlag


onready var NodeUtil = preload("res://src/utils/NodeUtil.gd").new()
onready var BigFlag = $BigFlag
onready var SmallFlag = $SmallFlag
export var team_id = 0
export var first_capture = true


func _ready():
	play_animation(BigFlag, "default")
	play_animation(SmallFlag, "default")


func setup(_team_id):
	team_id = _team_id


func change_physic(mode):
	set_deferred("mode", mode)


func play_animation(Flag, animation_name):
	if Flag.is_playing() and Flag.animation == animation_name:
		return

	Flag.play(animation_name)


func _on_body_entered(body):
	if SmallFlag.visible:
		return

	if not (body is Player):
		return

	# Flag captured
	if body.team_id != team_id:
		first_capture = false
		play_animation(BigFlag, "collected")
		SmallFlag.visible = true

		NodeUtil.reparent(self, body)
		GameEvent.emit_signal("CTF_capture_flag", team_id)
		return

	# Flag returned
	if not first_capture:
		GameEvent.emit_signal("CTF_return_flag", team_id)
		queue_free()


func _on_touchdown(_body):
	change_physic(MODE_KINEMATIC)
