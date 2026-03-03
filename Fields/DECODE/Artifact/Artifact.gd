
extends RigidBody3D
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
