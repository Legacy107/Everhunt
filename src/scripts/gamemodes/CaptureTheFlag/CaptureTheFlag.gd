extends Gamemode


onready var FlagStation = preload("res://src/components/gamemodes/CaptureTheFlag/FlagStation.tscn")
onready var GamemodeContainer = get_node("/root/Game/World/GamemodeContainer")
var flag_positions = load("res://src/utils/resources/MapInfo.tres").CTF_flag_positions


func _init().(3):
	pass


func setup():
	.setup()
	var flag_station_instances = [FlagStation.instance(), FlagStation.instance()]
	for id in flag_station_instances.size():
		flag_station_instances[id].setup(id)
		flag_station_instances[id].global_position = flag_positions[id]
		GamemodeContainer.add_child(flag_station_instances[id])
