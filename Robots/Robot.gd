class_name Robot
extends CharacterBody3D

#@export var driverDevices: Array[int] = [0, 1]
@export var driver1: int = 0
@export var driver2: int = 1
@export var driverContexts: Array[GUIDEMappingContext] = []
@export_enum("Blue", "Red") var alliance := 0

signal collection(collected: Array)

func _ready() -> void:
	driverContexts[0] = driverContexts[0].duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	driverContexts[1] = driverContexts[1].duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	GUIDE.enable_mapping_context(driverContexts[0])
	GUIDE.enable_mapping_context(driverContexts[1])
	for m in driverContexts[0].mappings:
		m.input_mappings[0].input.joy_index = driver1
	for m in driverContexts[1].mappings:
		m.input_mappings[0].input.joy_index = driver2
		
func _process(delta: float) -> void:
	pass
