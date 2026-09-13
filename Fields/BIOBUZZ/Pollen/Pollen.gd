class_name Pollen
extends RigidBody3D

var reset_state = false
var moveVector: Vector3

var launchZone = false
var launchSource: Robot = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _integrate_forces(state):
	if reset_state:
		state.transform = Transform3D(Basis.IDENTITY, moveVector)
		reset_state = false

func move_body(targetPos: Vector3):
	moveVector = targetPos
	reset_state = true
