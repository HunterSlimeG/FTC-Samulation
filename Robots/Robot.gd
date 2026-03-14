class_name Robot
extends CharacterBody3D

@export var drivers = [0, 1]
var driver1: GUIDEMappingContext
@export_enum("Blue", "Red") var alliance := 0

func _ready() -> void:
	GUIDE.enable_mapping_context(driver1)
