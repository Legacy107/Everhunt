extends Gamemode


onready var FlagStation = preload("res://src/components/gamemodes/CaptureTheFlag/FlagStation.tscn")
onready var GameContainer = get_node("/root/Game/World/GamemodeContainer")
var flag_positions = load("res://src/utils/resources/MapInfo.tres").CTF_flag_positions


func _init().(3):
	pass


func setup():
	.setup()
	var flag_stations = [FlagStation.instance(), FlagStation.instance()]
	for station_id in flag_stations.size():
		flag_stations[station_id].setup(station_id)
		flag_stations[station_id].global_position = flag_positions[station_id]
		GameContainer.add_child(flag_stations[station_id])
