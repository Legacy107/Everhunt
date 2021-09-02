extends Gamemode


onready var FlagStation = preload("res://src/components/gamemodes/CaptureTheFlag/FlagStation.tscn")
onready var GamemodeContainer = get_node("/root/Game/World/GamemodeContainer")
var flag_positions = load("res://src/utils/resources/MapInfo.tres").CTF_flag_positions


func _init().(3):
	pass


func setup():
	.setup()
	var flag_stations_instances = [FlagStation.instance(), FlagStation.instance()]
	for station_id in flag_stations_instances.size():
		flag_stations_instances[station_id].setup(station_id)
		flag_stations_instances[station_id].global_position = flag_positions[station_id]
		GamemodeContainer.add_child(flag_stations_instances[station_id])
