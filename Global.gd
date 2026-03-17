extends Node

var field = ""
var drivers: Array[GUIDEMappingContext] = [preload("res://Drivers/Driver0.tres"), preload("res://Drivers/Driver1.tres"), preload("res://Drivers/Driver2.tres"), preload("res://Drivers/Driver3.tres"), preload("res://Drivers/Driver4.tres"), null]

var fullscreen = false

func _input(event: InputEvent) -> void:
	GUIDE.enable_mapping_context(Global.drivers[0])
	GUIDE.enable_mapping_context(Global.drivers[1])
	GUIDE.enable_mapping_context(Global.drivers[2])
	GUIDE.enable_mapping_context(Global.drivers[3])
	GUIDE.enable_mapping_context(Global.drivers[4])
	if event.is_action_pressed("FullScreen"):
		fullscreen = not fullscreen
		if fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
