extends Node


var PreloadedAbilities = {
	"Bullet" : preload("res://src/components/Bullet.tscn"),
	"HomingMissile" : preload("res://src/components/HomingMissile.tscn")
}


onready var WorldNode = get_node("/root/World")


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
		Ability.setup(PlayerContainer.get_node(state["name"] + "/Hand"), state["dir"])


remote func update_player_state(player_id, state):
	var PlayerContainer = WorldNode.get_node_or_null("Players/" + str(player_id))
	
	if PlayerContainer and !PlayerContainer.is_network_master():
		var Player = PlayerContainer.get_node_or_null(state["name"])
		
		Player.position = state["pos"]
		Player.get_node("Sprite").flip_h = state["flip"]
		Player.get_node("Hand").position.x = state["hand_pos"]
		play_anim(state["anim"], Player.get_node("AnimationPlayer"))
	
	if PlayerContainer:
		var Mouse = PlayerContainer.get_node_or_null(state["mouse_name"])
		
		Mouse.position = state["mouse_pos"]


remote func update_bullet_state(player_id, state):
	var PlayerContainer = WorldNode.get_node_or_null("Players/" + str(player_id))
	
	if PlayerContainer and !PlayerContainer.is_network_master():
		var Bullet = PlayerContainer.get_node_or_null(state["name"])
		
		if Bullet:
			Bullet.position = state["pos"]


func play_anim(anim_name, AnimPlayer):
	if AnimPlayer.is_playing() and AnimPlayer.current_animation == anim_name:
		return
	
	AnimPlayer.play(anim_name)