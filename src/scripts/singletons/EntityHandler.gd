extends Node


var PreloadedAbilities = {
	"Bullet" : preload("res://src/components/Bullet.tscn"),
	"HomingMissile" : preload("res://src/components/HomingMissile.tscn")
}


onready var WorldNode = get_node("/root/Game/World")


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




remote func activate_ability(player_id, state):
	var PlayerContainer = WorldNode.get_node_or_null("Players/" + str(player_id))

	if PlayerContainer:
		var Ability = PreloadedAbilities[state["ability"]].instance()

		Ability.set_network_master(player_id)
		PlayerContainer.add_child(Ability)
		Ability.setup(PlayerContainer.get_node(state["name"] + "/Hand"), state["mouse_direction"])


remote func update_player_state(player_id, state):
	var PlayerContainer = WorldNode.get_node_or_null("Players/" + str(player_id))

	if PlayerContainer and !PlayerContainer.is_network_master():
		var Player = PlayerContainer.get_node_or_null(state["name"])

		Player.position = state["position"]
		Player.get_node("Sprite").flip_h = state["flip"]
		Player.get_node("Hand").position.x = state["hand_position"]
		play_animation(state["animation"], Player.get_node("AnimationPlayer"))

	if PlayerContainer:
		var Mouse = PlayerContainer.get_node_or_null(state["mouse_name"])

		Mouse.position = state["mouse_position"]


remote func set_players_team_id(player_ids):
	for index in player_ids.size():
		var Player = get_node("/root/Game/World/Players/%d/Player" % player_ids[index])
		Player.team_id = index % 2


remote func update_bullet_state(player_id, state):
	var PlayerContainer = WorldNode.get_node_or_null("Players/" + str(player_id))

	if PlayerContainer and !PlayerContainer.is_network_master():
		var Bullet = PlayerContainer.get_node_or_null(state["name"])

		if Bullet:
			Bullet.position = state["position"]


func play_animation(animation_name, AnimPlayer):
	if AnimPlayer.is_playing() and AnimPlayer.current_animation == animation_name:
		return

	AnimPlayer.play(animation_name)
