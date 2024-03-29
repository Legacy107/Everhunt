extends Node


export var SINGLEPLAYER = false


var Player = preload("res://src/components/others/Player.tscn")
var Node = preload("res://src/components/others/Node.tscn")
var Cards = {
	"BulletCard" : preload("res://src/components/cards/BulletCard.tscn"),
	"HomingMissileCard" : preload("res://src/components/cards/HomingMissileCard.tscn"),
}


var WorldNode


var network = NetworkedMultiplayerENet.new()
var ip = "localhost"
var port = 1909


var unique_id = 0
var player_team_ids = {}


func connect2server():
	WorldNode = get_node("/root/Game/World")

	if SINGLEPLAYER:
		ip = "localhost"
		port = 1909

	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	unique_id = get_tree().get_network_unique_id()

	network.connect("connection_failed", self, "_connection_failed")
	network.connect("connection_succeeded", self, "_connection_succeeded")

	if SINGLEPLAYER:
		append_player(unique_id, 0)


func disconnect_from_server():
	network.disconnect("connection_failed", self, "_connection_failed")
	network.disconnect("connection_succeeded", self, "_connection_succeeded")

	get_tree().set_network_peer(null)
	network.close_connection()


func _connection_failed():
	print("Failed to connect")


func _connection_succeeded():
	print("Succeeded to connect")

# Tell the server to run the func on all clients
remote func synchronize(node_path, func_name, state):
	if not SINGLEPLAYER:
		rpc_id(1, "synchronize", node_path, func_name, state)
	else:
		get_node(node_path).call(func_name, state)


remote func synchronize_unreliable(node_path, func_name, state):
	if not SINGLEPLAYER:
		rpc_unreliable_id(1, "synchronize", node_path, func_name, state)
	else:
		get_node(node_path).call(func_name, state)

# Run the func on this client and tell the server to run the func on all OTHER clients
remote func synchronize_client(node_path, func_name, state):
	if not SINGLEPLAYER:
		rpc_id(1, "synchronize_client", node_path, func_name, state)

	get_node(node_path).call(func_name, state)


remote func synchronize_client_unreliable(node_path, func_name, state):
	if not SINGLEPLAYER:
		rpc_unreliable_id(1, "synchronize_client", node_path, func_name, state)

	get_node(node_path).call(func_name, state)

# The server calls these funcs so it is best that you do not touch these
remote func s_synchronize(node_path, func_name, state):
	if get_node_or_null(node_path):
		get_node(node_path).call(func_name, state)


remote func s_synchronize_client(node_path, func_name, state, rpc_sender_id):
	if get_node_or_null(node_path) and unique_id != rpc_sender_id:
		get_node(node_path).call(func_name, state)




remote func return_player_team_ids(s_player_team_ids):
	player_team_ids = s_player_team_ids

	for id in s_player_team_ids:
		if unique_id != id:
			append_player(id, s_player_team_ids[id])


remote func return_connected_player_team_id(s_player_id, s_team_id):
	player_team_ids[s_player_id] = s_team_id

	GameEvent.emit_signal("player_connected", s_player_id, s_team_id)

	append_player(s_player_id, s_team_id)


remote func return_disconnected_player_team_id(s_player_id):
	GameEvent.emit_signal("player_disconnected", s_player_id)

	player_team_ids.erase(s_player_id)

	call_deferred("erase_player", s_player_id)




func append_player(player_id, team_id):
	var NodeInstance = Node.instance()
	var PlayerInstance = Player.instance()

	NodeInstance.set_network_master(player_id)
	NodeInstance.set_name(str(player_id))

	WorldNode.get_node("EntityContainer").add_child(NodeInstance)

	PlayerInstance.set_network_master(player_id)
	PlayerInstance.set_name(str(player_id))
	PlayerInstance.team_id = team_id
	PlayerInstance.position = WorldNode.get_node("SpawnContainer/Spawn" + str(team_id)).position

	WorldNode.get_node("PlayerContainer").add_child(PlayerInstance)

	if not PlayerInstance.ready:
		yield(PlayerInstance, "ready")

	GameEvent.emit_signal("player_appended", player_id, team_id)

	append_card(PlayerInstance, Cards["BulletCard"])
	append_card(PlayerInstance, Cards["HomingMissileCard"])


func erase_player(player_id):
	GameEvent.emit_signal("player_erased", player_id)

	WorldNode.get_node("EntityContainer/" + str(player_id)).call_deferred("queue_free")
	WorldNode.get_node("PlayerContainer/" + str(player_id)).call_deferred("queue_free")


func append_card(Player_, Card_):
	var CardInstance = Card_.instance()

	CardInstance.setup(Player_)

	Player_.add_child(CardInstance)
