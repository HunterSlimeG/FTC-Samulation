class_name Nectar
extends RigidBody3D

var reset_state = false
var moveVector: Vector3

var launchZone = false
var launchSource: Robot = null

@export_enum("Red", "Blue") var color := 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match color:
		0:
			$MeshInstance3D.mesh = load("res://Fields/BIOBUZZ/Nectar/Red.res")
		1:
			$MeshInstance3D.mesh = load("res://Fields/BIOBUZZ/Nectar/Blue.res")

func _integrate_forces(state):
	if reset_state:
		state.transform = Transform3D(Basis.IDENTITY, moveVector)
		reset_state = false

func move_body(targetPos: Vector3):
	moveVector = targetPos
	reset_state = true
