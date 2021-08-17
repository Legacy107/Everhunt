extends Node


var SINGLEPLAYER = false


var PreloadedPlayer = preload("res://src/components/Player.tscn")


onready var WorldNode = get_node("/root/Game/World")


var network = NetworkedMultiplayerENet.new()
var ip = 'localhost'
var port = 1909


var unique_id = 0
var player_ids = []


func _ready():
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	unique_id = get_tree().get_network_unique_id()
	
	network.connect("connection_failed", self, "_connection_failed")
	network.connect("connection_succeeded", self, "_connection_succeeded")
	
	if SINGLEPLAYER:
		append_player(unique_id)


func _connection_failed():
	print("Failed to connect")


func _connection_succeeded():
	print("Succeeded to connect")


remote func synchronize(func_name, state):
	if !ServerHandler.SINGLEPLAYER:
		rpc_id(1, "synchronize", func_name, state)
	else:
		call(func_name, ServerHandler.unique_id, state)


remote func synchronize_unreliable(func_name, state):
	if !ServerHandler.SINGLEPLAYER:
		rpc_unreliable_id(1, "synchronize_unreliable", func_name, state)
	else:
		call(func_name, ServerHandler.unique_id, state)




remote func return_connected_player(s_player_id):
	player_ids.append(s_player_id)
	
	append_player(s_player_id)


remote func return_connected_players(s_player_ids):
	player_ids = s_player_ids
	
	for player_id in player_ids:
		if player_id != unique_id:
			append_player(player_id)


remote func return_disconnected_player(s_player_id):
	player_ids.erase(s_player_id)
	
	erase_player(s_player_id)




func append_player(player_id):
	var PlayerContainer = PreloadedPlayer.instance()
	var Player = PlayerContainer.get_node("Player")
	
	PlayerContainer.set_network_master(player_id)
	PlayerContainer.set_name(str(player_id))
	Player.set_network_master(player_id)
	Player.position = WorldNode.get_node("Spawns/Spawn" + str(player_id % 4 + 1)).position
	
	WorldNode.get_node("Players").add_child(PlayerContainer)


func erase_player(player_id):
	WorldNode.get_node("Players/" + str(player_id)).queue_free()
