extends Gamemode


onready var FlagStation = preload("res://src/components/gamemodes/CaptureTheFlag/FlagStation.tscn")
onready var GameContainer = get_node("/root/Game/World/GameContainer")
var FLAG_SPOTS = [Vector2(288, 496), Vector2(1440, 496)]


func _init().(3):
	pass


func setup():
	.setup()
	var flag_stations = [FlagStation.instance(), FlagStation.instance()]
	for station_id in flag_stations.size():
		flag_stations[station_id].setup(station_id)
		flag_stations[station_id].global_position = FLAG_SPOTS[station_id]
		GameContainer.add_child(flag_stations[station_id])
