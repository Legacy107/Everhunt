extends TextureButton


var menu_scene_path = load("res://src/utils/resources/SceneList.tres").menu

var button_pressed_debounce = true


func _on_pressed():
	if button_pressed_debounce:
		button_pressed_debounce = false

		SceneHandler.change_scene(menu_scene_path)
		yield(SceneHandler, "scene_changed")
		ServerHandler.disconnect_from_server()

		button_pressed_debounce = true
