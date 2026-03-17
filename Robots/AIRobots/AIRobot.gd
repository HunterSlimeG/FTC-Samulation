class_name AIRobot
extends CharacterBody3D

@export_enum("Blue", "Red") var alliance := 0

signal collection(collected: Array)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
