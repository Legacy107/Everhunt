extends TextureButton


var menu_scene_path = load("res://src/utils/resources/SceneList.tres").menu


func _on_pressed():
	if not disabled:
		disabled = true

		SceneHandler.change_scene(menu_scene_path)
		yield(SceneHandler, "scene_changed")
		ServerHandler.disconnect_from_server()

		disabled = false
