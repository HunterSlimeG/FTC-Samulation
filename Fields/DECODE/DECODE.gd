extends Field

var goal= true
# Called when the node enters the scene tree for the first time.
var tag = "res://Fields/DECODE/AprilTags/AprilTag ("+str(randi_range(1, 3))+").png"
func _ready() -> void:
	$AprilTags/Obelisk.texture = load(tag)
	$DECODEOverlay/Sprite2D.texture = load(tag)

func _process(delta: float) -> void:
	if goal:
		$Robot/Patton.targetPos = $Goals/Blue.global_position
	else:
		$Robot/Patton.targetPos = $Goals/Red.global_position

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("SwitchCams"):
		$Robot/Patton/Turret/Camera3D.current = not $Robot/Patton/Turret/Camera3D.current
	if event.device==1 or Input.get_joy_name(1)=="":
		if event.is_action_pressed("Square"):
			goal = not goal


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
	$Robot/Patton.transform = transform
	for a in $Artifacts.get_children():
		var art: Artifact = a.get_node("Artifact")
		art.freeze = true
		art.linear_velocity = Vector3.ZERO
		art.angular_velocity = Vector3.ZERO
		art.move_body(a.global_position)
		art.freeze = false
	for art: Artifact in $Robot/Patton.intakeArtifacts:
		art.freeze = true
		art.linear_velocity = Vector3.ZERO
		art.angular_velocity = Vector3.ZERO
		art.move_body(art.get_parent().global_position)
		art.visible = true
		art.freeze = false
		art.get_node("CollisionShape3D").disabled = false


func _on_blue_g_body_entered(body: Node3D) -> void:
	if body is Robot:
		$AnimationPlayer.play("OpenBlue", -1, 1.5)
		closestArtifact($"Gates/B").apply_central_impulse(Vector3(0, 0, 0.5))

func _on_red_g_body_entered(body: Node3D) -> void:
	if body is Robot:
		$AnimationPlayer.play("OpenRed", -1, 1.5)
		closestArtifact($"Gates/R").apply_central_impulse(Vector3(0, 0, 0.5))


func _on_blue_g_body_exited(body: Node3D) -> void:
	if body is Robot:
		$AnimationPlayer.play_backwards("OpenBlue")


func _on_red_g_body_exited(body: Node3D) -> void:
	if body is Robot:
		$AnimationPlayer.play_backwards("OpenRed")
		
func closestArtifact(gate: Node3D) -> Artifact:
	var closest = null
	for a in $Artifacts.get_children():
		var art: Artifact = a.get_node("Artifact")
		if closest==null or gate.position.distance_to(art.position)<gate.position.distance_to(closest.position):
			closest = art
	return closest
