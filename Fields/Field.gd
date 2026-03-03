class_name Field
extends Node3D


func reload():
	get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get("res://Fields/"+Global.field+"/"+Global.field+".scn"))
