extends Node


var SINGLEPLAYER = false


var Player = preload("res://src/components/others/Player.tscn")
var Node = preload("res://src/components/others/Node.tscn")


onready var WorldNode = get_node("/root/World")


var network = NetworkedMultiplayerENet.new()
var ip = "localhost"
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

# Tell the server to run the func on all clients
remote func synchronize(path, func_name, state):
	if not SINGLEPLAYER:
		rpc_id(1, "synchronize", path, func_name, state)
	else:
		get_node(path).call(func_name, state)


remote func synchronize_unreliable(path, func_name, state):
	if not SINGLEPLAYER:
		rpc_unreliable_id(1, "synchronize", path, func_name, state)
	else:
		get_node(path).call(func_name, state)

# Run the func on this client and tell the server to run the func on all OTHER clients
remote func synchronize_client(path, func_name, state):
	if not SINGLEPLAYER:
		rpc_id(1, "synchronize_client", path, func_name, state)

	get_node(path).call(func_name, state)


remote func synchronize_client_unreliable(path, func_name, state):
	if not SINGLEPLAYER:
		rpc_unreliable_id(1, "synchronize_client", path, func_name, state)

	get_node(path).call(func_name, state)

# The server calls these funcs so it is best that you do not touch these
remote func s_synchronize(path, func_name, state):
	if get_node_or_null(path):
		get_node(path).call(func_name, state)


remote func s_synchronize_client(path, func_name, state, rpc_sender_id):
	if get_node_or_null(path) and unique_id != rpc_sender_id:
		get_node(path).call(func_name, state)




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
	var NodeInstance = Node.instance()

	NodeInstance.set_network_master(player_id)
	NodeInstance.set_name(str(player_id))

	WorldNode.get_node("EntityContainer").add_child(NodeInstance)

	var PlayerInstance = Player.instance()

	PlayerInstance.set_network_master(player_id)
	PlayerInstance.set_name(str(player_id))
	PlayerInstance.position = WorldNode.get_node("Spawns/Spawn1").position

	WorldNode.get_node("PlayerContainer").add_child(PlayerInstance)


func erase_player(player_id):
	WorldNode.get_node("EntityContainer/" + str(player_id)).queue_free()
	WorldNode.get_node("PlayerContainer/" + str(player_id)).queue_free()
