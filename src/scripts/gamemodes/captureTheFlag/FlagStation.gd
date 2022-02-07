extends Area2D


onready var Flag = preload("res://src/components/gamemodes/captureTheFlag/Flag.tscn")

export var team_id = 0
export var has_flag = true


func _ready():
# warning-ignore:return_value_discarded
	GameEvent.connect("CTF_capture_flag", self, "_on_CTF_capture_flag")
# warning-ignore:return_value_discarded
	GameEvent.connect("CTF_return_flag", self, "_on_CTF_return_flag")
# warning-ignore:return_value_discarded
	GameEvent.connect("CTF_drop_flag", self, "_on_CTF_drop_flag")

	if has_flag:
		spawn_flag()


func setup(_team_id):
	team_id = _team_id


func spawn_flag(flag_global_position=global_position):
	var FlagInstance = Flag.instance()

	FlagInstance.setup(team_id)
	call_deferred("add_child", FlagInstance)
	FlagInstance.set_deferred("global_position", flag_global_position)
	FlagInstance.set_deferred("linear_velocity", Vector2(0, 0))
	has_flag = true

	return FlagInstance


func _on_body_entered(body):
	if has_flag and (body is CTFFlag) and body.team_id != team_id:
		GameEvent.emit_signal("increase_score", team_id, 1)
		GameEvent.emit_signal("CTF_return_flag", body.team_id)

		body.queue_free()


func _on_CTF_capture_flag(_team_id):
	if team_id == _team_id:
		has_flag = false


func _on_CTF_return_flag(_team_id):
	if team_id == _team_id:
		spawn_flag()


func _on_CTF_drop_flag(_team_id, _flag_global_position):
	if team_id == _team_id:
		spawn_flag(_flag_global_position).drop()
