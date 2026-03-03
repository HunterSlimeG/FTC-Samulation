extends Field


# Called when the node enters the scene tree for the first time.
var tag = "res://Fields/DECODE/AprilTags/AprilTag ("+str(randi_range(1, 3))+").png"
func _ready() -> void:
	Global.field = "DECODE"
	$AprilTags/Obelisk.texture = load(tag)
	$DECODEOverlay/Sprite2D.texture = load(tag)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func returnArtifact(art: Artifact):
	if art.position.x>0:
		art.position = $"Misc/Blue Spawner".position
	elif art.position.x<0:
		art.position = $"Misc/Red Spawner".position
	else:
		art.position = get_node(["Misc/Red Spawner", "Misc/Blue Spawner"].pick_random()).position
	art.linear_velocity = Vector3.ZERO
	art.angular_velocity = Vector3.ZERO

func _on_area_3d_body_exited(body: PhysicsBody3D) -> void:
	if body is Artifact:
		returnArtifact(body)
