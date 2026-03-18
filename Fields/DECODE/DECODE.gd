extends Field

var goal = true
@onready var cams: Array[Camera3D] = [get_node("Camera3D"), get_node("BlueCam"), get_node("RedCam")]
var cam = 0

var tag = "res://Fields/DECODE/AprilTags/AprilTag ("+str(randi_range(1, 3))+").png"

func _ready() -> void:
	$"Robot/B/19954B".targetPos = $Goals/Blue.global_position
	$"Robot/R/19954R".targetPos = $Goals/Red.global_position
	if $"Robot/B/19954B" is AIRobot:
		$"Robot/B/19954B".gatePosition = $Gates/B/BlueG/CollisionShape3D.global_position
	if $"Robot/R/19954R" is AIRobot:
		$"Robot/R/19954R".gatePosition = $Gates/R/RedG/CollisionShape3D.global_position
	Global.baseControls.mappings[0].action.completed.connect(camSwitch)
	Global.baseControls.mappings[1].action.completed.connect(reload)
	reload()

func _process(delta: float) -> void:
	#updateCurve()
	$DECODEOverlay.updateArtifacts($"Robot/B/19954B".intakeArtifacts, $"Robot/R/19954R".intakeArtifacts)

func _input(event: InputEvent) -> void:
	pass

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
	$Robot.process_mode = Node.PROCESS_MODE_DISABLED
	$Timer.process_mode = Node.PROCESS_MODE_INHERIT
	$DECODEOverlay/Timer.process_mode = Node.PROCESS_MODE_DISABLED
	$Timer.start()
	$DECODEOverlay.countDown = true
	$DECODEOverlay/CenterContainer/Label.text = "1:30"
	tag = "res://Fields/DECODE/AprilTags/AprilTag ("+str(randi_range(1, 3))+").png"
	$AprilTags/Obelisk.texture = load(tag)
	$DECODEOverlay/Sprite2D.texture = load(tag)
	$"Robot/B/19954B".transform = transform
	$"Robot/R/19954R".transform = transform
	for a in $Artifacts.get_children():
		var art: Artifact = a.get_node("Artifact")
		art.freeze = true
		art.linear_velocity = Vector3.ZERO
		art.angular_velocity = Vector3.ZERO
		art.move_body(a.global_position)
		art.freeze = false
		art.get_node("CollisionShape3D").disabled = false
		art.visible = true
	$"Robot/B/19954B".intakeArtifacts.clear()
	$"Robot/R/19954R".intakeArtifacts.clear()
	$DECODEOverlay.scoreB = 0
	$DECODEOverlay.scoreR = 0
	var hs := FileAccess.open("res://Fields/DECODE/HS.txt", FileAccess.READ)
	$DECODEOverlay/CenterContainer3/Label.text = "High Score: "+hs.get_as_text()


func _on_blue_g_body_entered(body: Node3D) -> void:
	if body is Robot or body is AIRobot:
		$AnimationPlayer.play("OpenBlue", -1, 1.5)
		await $AnimationPlayer.animation_finished
		closestArtifact($"Gates/B").apply_central_impulse(Vector3(0, 0, 2))

func _on_red_g_body_entered(body: Node3D) -> void:
	if body is Robot or body is AIRobot:
		$AnimationPlayer.play("OpenRed", -1, 1.5)
		await $AnimationPlayer.animation_finished
		closestArtifact($"Gates/R").apply_central_impulse(Vector3(0, 0, 2))

func _on_blue_g_body_exited(body: Node3D) -> void:
	if body is Robot or body is AIRobot:
		$AnimationPlayer.play_backwards("OpenBlue")

func _on_red_g_body_exited(body: Node3D) -> void:
	if body is Robot or body is AIRobot:
		$AnimationPlayer.play_backwards("OpenRed")
		
func closestArtifact(gate: Node3D) -> Artifact:
	var closest = null
	for a in $Artifacts.get_children():
		var art: Artifact = a.get_node("Artifact")
		if closest==null or gate.global_position.distance_to(art.global_position)<gate.global_position.distance_to(closest.global_position):
			closest = art
	return closest

func camSwitch():
	cam += 1
	cam %= 3
	cams[cam-1].current = false
	cams[cam].current = true
	cams[(cam+1)%3].current = false

func updateCurve():
	pass
	#$Path3D.curve.clear_points()
	#$Path3D.curve.add_point($Robot/19954/Turret/MeshInstance3D.global_position)
	#if goal:
		#$Path3D.curve.add_point($Goals/Blue.global_position)
	#else:
		#$Path3D.curve.add_point($Goals/Red.global_position)
	#for i in range($Robot/19954.dist):
		#var val = i*tan($Robot/19954.targetAng) - ((24.5*(i**2))/(2*($Robot/19954.targetV**2)*(cos($Robot/19954.targetAng)**2)))
		#$Path3D.curve.add_point($Goals/Red.global_position+Vector3(0, val, 0))


func _on_blue_body_entered(body: Node3D) -> void:
	if body is Artifact:
		$DECODEOverlay.scoreB += 1


func _on_red_body_entered(body: Node3D) -> void:
	if body is Artifact:
		$DECODEOverlay.scoreR += 1


func _on_timer_timeout() -> void:
	$Robot.process_mode = Node.PROCESS_MODE_INHERIT
	$Goals/Blue/Blue/CollisionShape3D.disabled = false
	$Goals/Red/Red/CollisionShape3D.disabled = false
	$Timer.process_mode = Node.PROCESS_MODE_DISABLED
	$DECODEOverlay/Timer.process_mode = Node.PROCESS_MODE_INHERIT
	$DECODEOverlay/Timer.start()
	$DECODEOverlay.countDown = false


func _on_decode_overlay_match_finished() -> void:
	$Robot.process_mode = Node.PROCESS_MODE_DISABLED
	$Goals/Blue/Blue/CollisionShape3D.disabled = true
	$Goals/Red/Red/CollisionShape3D.disabled = true
