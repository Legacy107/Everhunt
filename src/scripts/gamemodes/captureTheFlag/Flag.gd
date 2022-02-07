class_name CTFFlag

extends RigidBody2D


onready var NodeUtil = preload("res://src/utils/NodeUtil.gd").new()
onready var SmallFlag = $SmallFlag
onready var BigFlag = $BigFlag

export var team_id = 0
export var recapturable = false


func _ready():
	NodeUtil.play_animation(BigFlag, "idle")
	NodeUtil.play_animation(SmallFlag, "idle")
	SmallFlag.visible = false


func setup(_team_id):
	team_id = _team_id


func change_physics(mode):
	set_deferred("mode", mode)


func drop():
	recapturable = true

	change_physics(MODE_RIGID)


func _on_body_entered(body):
	# If flag is on a player
	if SmallFlag.visible:
		return

	if not (body is Player):
		return

	# If flag is captured
	if body.team_id != team_id:
		body.flag_team_id = team_id
		NodeUtil.play_animation(BigFlag, "collected")
		NodeUtil.play_animation(SmallFlag, "collected")
		SmallFlag.visible = true

		NodeUtil.reparent(self, body)
		change_physics(MODE_KINEMATIC)
		set_deferred("position", Vector2(0, 0))

		GameEvent.emit_signal("CTF_capture_flag", team_id)
		return

	# If flag is returned
	if recapturable:
		GameEvent.emit_signal("CTF_return_flag", team_id)
		queue_free()


func _on_touchdown(_body):
	change_physics(MODE_KINEMATIC)
