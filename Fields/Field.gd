class_name Field
extends Node3D


func _ready() -> void:
	Global.baseControls.mappings[2].action.triggered.connect(mainMenu)
	
func mainMenu():
	get_tree().change_scene_to_file("res://Menu/Menu.tscn")
