extends Node

var field = ""

var fullscreen = false
var baseControls = preload("res://BaseControls.tres")

func _input(event: InputEvent) -> void:
	GUIDE.enable_mapping_context(baseControls)
	if event.is_action_pressed("FullScreen"):
		fullscreen = not fullscreen
		if fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
