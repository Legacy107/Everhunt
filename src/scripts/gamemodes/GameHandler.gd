extends Node


onready var CaptureTheFlag = preload("res://src/components/gamemodes/capture_the_flag/CaptureTheFlag.tscn").instance()


func _ready():
	add_child(CaptureTheFlag)
	CaptureTheFlag.setup()
