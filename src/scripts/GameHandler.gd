extends Node


onready var CaptureTheFlag = preload("res://src/components/gamemodes/captureTheFlag/CaptureTheFlag.tscn").instance()


func _ready():
	add_child(CaptureTheFlag)
	CaptureTheFlag.setup()
	GameEvent.emit_signal("round_setup", CaptureTheFlag.winning_score)
