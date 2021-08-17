extends Node2D


signal increase_score(team_id)

onready var CaptureTheFlag = preload("res://src/components/gamemodes/CaptureTheFlag.tscn").instance()


func _ready():
	add_child(CaptureTheFlag)
	CaptureTheFlag.setup()


func increase_score(team_id):
	emit_signal("increase_score", team_id)
