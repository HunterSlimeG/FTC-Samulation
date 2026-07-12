extends Node

var field = ""

var fullscreen = false
var baseControls = preload("res://BaseControls.tres")

var cursorContexts = [preload("res://Menu/Cursor/Contexts/CursorControls1.tres"), preload("res://Menu/Cursor/Contexts/CursorControls2.tres"), preload("res://Menu/Cursor/Contexts/CursorControls3.tres"), preload("res://Menu/Cursor/Contexts/CursorControls4.tres")]


func _process(delta: float) -> void:
	if not GUIDE.is_mapping_context_enabled(baseControls):
		GUIDE.enable_mapping_context(baseControls)
		baseControls.mappings[3].action.completed.connect(toggleFullScreen)

func toggleFullScreen():
	fullscreen = not fullscreen
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
