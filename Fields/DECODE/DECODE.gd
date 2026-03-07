extends Field

var goal = true
@onready var cams: Array[Camera3D] = [get_node("Camera3D"), get_node("BlueCam"), get_node("RedCam")]
#get_node("Robot/Patton/Turret/Camera3D"),
var cam = 0
# Called when the node enters the scene tree for the first time.
var tag = "res://Fields/DECODE/AprilTags/AprilTag ("+str(randi_range(1, 3))+").png"
func _ready() -> void:
	$AprilTags/Obelisk.texture = load(tag)
	$DECODEOverlay/Sprite2D.texture = load(tag)

func _process(delta: float) -> void:
	#updateCurve()
	$DECODEOverlay.artifactsB = $Robot/B/PattonB.intakeArtifacts
	$DECODEOverlay.artifactsR = $Robot/R/PattonR.intakeArtifacts
	$Robot/B/PattonB.targetPos = $Goals/Blue.global_position
	$Robot/R/PattonR.targetPos = $Goals/Red.global_position

func _input(event: InputEvent) -> void:
	#print(event.device)
	if event.is_action_pressed("SwitchCams"):
		cam += 1
		cam %= 3
		camSwitch()
	#elif event.device==$Robot/PattonB.drivers[1] or Input.get_joy_name($Robot/PattonB.drivers[1])=="":
		#pass
		#if event.is_action_pressed("Square"):
		#	goal = not goal
	if event.is_action_pressed("Reload"):
		reload()

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
	$Robot/B/PattonB.transform = transform
	$Robot/R/PattonR.transform = transform
	for a in $Artifacts.get_children():
		var art: Artifact = a.get_node("Artifact")
		art.freeze = true
		art.linear_velocity = Vector3.ZERO
		art.angular_velocity = Vector3.ZERO
		art.move_body(a.global_position)
		art.freeze = false
		art.get_node("CollisionShape3D").disabled = false
		art.visible = true
	$Robot/B/PattonB.intakeArtifacts.clear()
	$Robot/R/PattonR.intakeArtifacts.clear()


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

func camSwitch():
	cams[cam-1].current = false
	cams[cam].current = true
	cams[(cam+1)%3].current = false

func updateCurve():
	pass
	#$Path3D.curve.clear_points()
	#$Path3D.curve.add_point($Robot/Patton/Turret/MeshInstance3D.global_position)
	#if goal:
		#$Path3D.curve.add_point($Goals/Blue.global_position)
	#else:
		#$Path3D.curve.add_point($Goals/Red.global_position)
	#for i in range($Robot/Patton.dist):
		#var val = i*tan($Robot/Patton.targetAng) - ((24.5*(i**2))/(2*($Robot/Patton.targetV**2)*(cos($Robot/Patton.targetAng)**2)))
		#$Path3D.curve.add_point($Goals/Red.global_position+Vector3(0, val, 0))


func _on_blue_body_entered(body: Node3D) -> void:
	if body is Artifact:
		$DECODEOverlay.scoreB += 1


func _on_red_body_entered(body: Node3D) -> void:
	if body is Artifact:
		$DECODEOverlay.scoreR += 1
