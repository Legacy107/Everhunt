extends NinePatchRect


var game_scene_path = load("res://src/utils/resources/SceneList.tres").game

onready var IpInput = $Panel/MarginContainer/CenterContainer/IpInput
onready var PortInput = $Panel/MarginContainer/CenterContainer/PortInput


func _ready():
	IpInput.text = ServerHandler.ip
	PortInput.text = str(ServerHandler.port)


func _on_JoinButton_pressed():
	SceneChanger.change_scene(game_scene_path)


func _on_IpInput_text_changed(new_ip):
	ServerHandler.ip = new_ip


func _on_PortInput_text_changed(new_port):
	ServerHandler.port = int(new_port)
