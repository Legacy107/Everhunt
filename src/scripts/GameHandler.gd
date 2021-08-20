extends Node


onready var CaptureTheFlag = preload("res://src/components/gamemodes/CaptureTheFlag.tscn").instance()


func _ready():
	add_child(CaptureTheFlag)
	CaptureTheFlag.setup()
