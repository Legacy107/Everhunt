extends RigidBody2D

class_name CTFFlag


onready var NodeUtil = preload("res://src/utils/NodeUtil.gd").new()
onready var BigFlag = $BigFlag
onready var SmallFlag = $SmallFlag
export var team_id = 0
export var recapturable = false


func _ready():
	NodeUtil.play_animation(BigFlag, "idle")
	NodeUtil.play_animation(SmallFlag, "idle")


func setup(_team_id):
	team_id = _team_id


func change_physics(mode):
	set_deferred("mode", mode)


func _on_body_entered(body):
	# If flag is on a player
	if SmallFlag.visible:
		return

	if not (body is Player):
		return

	# If flag is captured
	if body.team_id != team_id:
		recapturable = true
		NodeUtil.play_animation(BigFlag, "collected")
		SmallFlag.visible = true

		NodeUtil.reparent(self, body)
		GameEvent.emit_signal("CTF_capture_flag", team_id)
		return

	# If flag is returned
	if recapturable:
		GameEvent.emit_signal("CTF_return_flag", team_id)
		queue_free()


func _on_touchdown(_body):
	change_physics(MODE_KINEMATIC)
