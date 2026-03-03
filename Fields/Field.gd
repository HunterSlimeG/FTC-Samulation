class_name Field
extends Node3D


func reload():
	get_tree().change_scene_to_file("res://Fields/"+Global.field+"/"+Global.field+".scn")
