class_name Robot
extends CharacterBody3D

@export var drivers = [1, 2]
var driver1: GUIDEMappingContext
var driver2: GUIDEMappingContext
@export_enum("Blue", "Red") var alliance := 0

signal collection(collected: Array)

func _ready() -> void:
	driver1 = Global.drivers[drivers[0]]
	driver2 = Global.drivers[drivers[1]]
	
func _process(delta: float) -> void:
	pass
