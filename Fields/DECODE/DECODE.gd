extends Field


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.field = "DECODE"
	$AprilTags/Obelisk.texture = load("res://Fields/DECODE/AprilTags/AprilTag ("+str(randi_range(1, 3))+").png")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_3d_body_exited(body: RigidBody3D) -> void:
	if body.position.x>0:
		body.position = $"Misc/Blue Spawner".position
	elif body.position.x<0:
		body.position = $"Misc/Red Spawner".position
	else:
		body.position = get_node(["Misc/Red Spawner", "Misc/Blue Spawner"].pick_random()).position
	body.linear_velocity = Vector3.ZERO
	body.angular_velocity = Vector3.ZERO
