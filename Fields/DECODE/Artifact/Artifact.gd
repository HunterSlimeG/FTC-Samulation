class_name Artifact
extends RigidBody3D

var reset_state = false
var moveVector: Vector3

@export_enum("Purple", "Green") var color := 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match color:
		0:
			$MeshInstance3D.mesh = load("res://Fields/DECODE/Artifact/Purple.res")
		1:
			$MeshInstance3D.mesh = load("res://Fields/DECODE/Artifact/Green.res")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	pass

func _integrate_forces(state):
	if reset_state:
		state.transform = Transform3D(Basis.IDENTITY, moveVector)
		reset_state = false

func move_body(targetPos: Vector3):
	moveVector = targetPos;
	reset_state = true;
