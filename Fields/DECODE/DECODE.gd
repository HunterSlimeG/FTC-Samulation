extends Field


# Called when the node enters the scene tree for the first time.
var tag = "res://Fields/DECODE/AprilTags/AprilTag ("+str(randi_range(1, 3))+").png"
func _ready() -> void:
	$AprilTags/Obelisk.texture = load(tag)
	$DECODEOverlay/Sprite2D.texture = load(tag)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("SwitchCams"):
		$Robot/Patton/Turret/Camera3D.current = not $Robot/Patton/Turret/Camera3D.current
		


func _on_area_3d_body_exited(body: PhysicsBody3D) -> void:
	if body is Artifact:
		if body.global_position.x>0:
			body.global_position = $"Misc/Blue Spawner".global_position
		elif body.global_position.x<0:
			body.global_position = $"Misc/Red Spawner".global_position
		else:
			body.global_position = get_node(["Misc/Red Spawner", "Misc/Blue Spawner"].pick_random()).global_position
		body.linear_velocity = Vector3.ZERO
		body.angular_velocity = Vector3.ZERO

func reload():
	super()
	tag = "res://Fields/DECODE/AprilTags/AprilTag ("+str(randi_range(1, 3))+").png"
	$AprilTags/Obelisk.texture = load(tag)
	$DECODEOverlay/Sprite2D.texture = load(tag)
	for a in $Artifacts.get_children():
		var art: RigidBody3D = a.get_node("Artifact")
		art.position = Vector3.ZERO
		art.linear_velocity = Vector3.ZERO
		art.angular_velocity = Vector3.ZERO
	$Robot/Patton.transform = transform


func _on_blue_g_body_entered(body: Node3D) -> void:
	if body is Robot:
		$AnimationPlayer.play("OpenBlue")


func _on_red_g_body_entered(body: Node3D) -> void:
	if body is Robot:
		$AnimationPlayer.play("OpenRed")


func _on_blue_g_body_exited(body: Node3D) -> void:
	if body is Robot:
		$AnimationPlayer.play_backwards("OpenBlue")


func _on_red_g_body_exited(body: Node3D) -> void:
	if body is Robot:
		$AnimationPlayer.play_backwards("OpenRed")
