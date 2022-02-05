class_name CTFFlag

extends RigidBody2D


onready var NodeUtil = preload("res://src/utils/NodeUtil.gd").new()
onready var BigFlag = $BigFlag
onready var SmallFlag = $SmallFlag


onready var WorldNode = get_node("/root/Game/World")


export var team_id = 0
export var recapturable = false


var player_id = -1


func _ready():
# warning-ignore:return_value_discarded
	ServerEvent.connect("player_disconnected", self, "_on_player_disconnected")
# warning-ignore:return_value_discarded
	ServerEvent.connect("player_erased", self, "_on_player_erased")

	NodeUtil.play_animation(BigFlag, "idle")
	NodeUtil.play_animation(SmallFlag, "idle")


func setup(_team_id):
	team_id = _team_id


func change_physics(mode):
	set_deferred("mode", mode)


func drop():
	recapturable = true
	NodeUtil.play_animation(BigFlag, "idle")
	NodeUtil.play_animation(SmallFlag, "idle")
	BigFlag.visible = true
	SmallFlag.visible = false
	player_id = -1

	NodeUtil.reparent(self, WorldNode)
	change_physics(MODE_RIGID)
	set_deferred("global_position", global_position)
	set_deferred("linear_velocity", Vector2(0, 0))


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
		change_physics(MODE_KINEMATIC)
		set_deferred("position", Vector2(0, 0))

		player_id = int(body.name)
		GameEvent.emit_signal("CTF_capture_flag", team_id)
		return

	# If flag is returned
	if recapturable:
		GameEvent.emit_signal("CTF_return_flag", team_id)
		queue_free()


func _on_touchdown(_body):
	change_physics(MODE_KINEMATIC)


func _on_player_disconnected(_player_id):
	if player_id == _player_id:
		drop()


func _on_player_erased(_player_id):
	if player_id == _player_id:
		drop()
