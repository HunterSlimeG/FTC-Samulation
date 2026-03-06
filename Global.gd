extends Node

var field = ""

var fullscreen = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("FullScreen"):
		fullscreen = not fullscreen
		if fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
