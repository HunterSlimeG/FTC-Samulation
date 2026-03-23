extends Field

var goal = true
@onready var cams: Array[Camera3D] = [get_node("Camera3D"), get_node("BlueCam"), get_node("RedCam")]
var cam = 0

var tag = "res://Fields/DECODE/AprilTags/AprilTag ("+str(randi_range(1, 3))+").png"

var blueGateOpener: Robot
var redGateOpener: Robot

func _ready() -> void:
	blueGateOpener = get_node("Robot/B/19954")
	redGateOpener = get_node("Robot/R/19954")
	$"Robot/B/19954".targetPos = $Goals/Blue.global_position
	$"Robot/R/19954".targetPos = $Goals/Red.global_position
	if $"Robot/B/19954" is AIRobot:
		$"Robot/B/19954".gatePosition = $Gates/B/BlueG/CollisionShape3D.global_position
	if $"Robot/R/19954" is AIRobot:
		$"Robot/R/19954".gatePosition = $Gates/R/RedG/CollisionShape3D.global_position
	Global.baseControls.mappings[0].action.completed.connect(camSwitch)
	Global.baseControls.mappings[1].action.completed.connect(reload)
	reload()

func _process(delta: float) -> void:
	#updateCurve()
	$DECODEOverlay.updateArtifacts($"Robot/B/19954".intakeArtifacts, $"Robot/R/19954".intakeArtifacts)

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
	$"Robot/B/19954".transform = transform
	$"Robot/R/19954".transform = transform
	for a in $Artifacts.get_children():
		var art: Artifact = a.get_node("Artifact")
		art.freeze = true
		art.linear_velocity = Vector3.ZERO
		art.angular_velocity = Vector3.ZERO
		art.move_body(a.global_position)
		art.freeze = false
		art.get_node("CollisionShape3D").disabled = false
		art.visible = true
	$"Robot/B/19954".intakeArtifacts.clear()
	$"Robot/R/19954".intakeArtifacts.clear()
	$DECODEOverlay.scoreB = 0
	$DECODEOverlay.scoreR = 0
	var hs := FileAccess.open("res://Fields/DECODE/HS.txt", FileAccess.READ)
	$DECODEOverlay/CenterContainer3/Label.text = "High Score:\n"+hs.get_as_text()


func _on_blue_g_body_entered(body: Node3D) -> void:
	if body is Robot:
		$AnimationPlayer.play("OpenBlue", -1, 1.5)
		await $AnimationPlayer.animation_finished
		closestArtifact($"Gates/B").apply_central_impulse(Vector3(0, 0, 1))
		blueGateOpener = body

func _on_red_g_body_entered(body: Node3D) -> void:
	if body is Robot:
		$AnimationPlayer.play("OpenRed", -1, 1.5)
		await $AnimationPlayer.animation_finished
		closestArtifact($"Gates/R").apply_central_impulse(Vector3(0, 0, 1))
		redGateOpener = body

func _on_blue_g_body_exited(body: Node3D) -> void:
	if body is Robot:
		$AnimationPlayer.play_backwards("OpenBlue")
		#blueGateOpener = null

func _on_red_g_body_exited(body: Node3D) -> void:
	if body is Robot:
		$AnimationPlayer.play_backwards("OpenRed")
		#redGateOpener = null
		
func closestArtifact(gate: Node3D) -> Artifact:
	var closest = null
	for a in $Artifacts.get_children():
		var art: Artifact = a.get_node("Artifact")
		if closest==null or gate.global_position.distance_to(art.global_position)<gate.global_position.distance_to(closest.global_position):
			closest = art
	return closest

func camSwitch():
	$SplitCam.visible = not $SplitCam.visible
	#cam += 1
	#cam %= 3
	#cams[cam-1].current = false
	#cams[cam].current = true
	#cams[(cam+1)%3].current = false

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


func _on_blue_over_body_entered(body: Node3D) -> void:
	if body is Artifact:
		if body.launchZone and body.launchSource.alliance==0:
			$DECODEOverlay.scoreB += 1
		else:
			$DECODEOverlay.scoreR += 15


func _on_red_over_body_entered(body: Node3D) -> void:
	if body is Artifact:
		if body.launchZone and body.launchSource.alliance==1:
			$DECODEOverlay.scoreR += 1
		else:
			$DECODEOverlay.scoreB += 15


func _on_timer_timeout() -> void:
	$Robot.process_mode = Node.PROCESS_MODE_INHERIT
	$Goals/Blue/Over/CollisionShape3D.disabled = false
	$Goals/Red/Over/CollisionShape3D.disabled = false
	$Goals/Blue/Class/CollisionShape3D.disabled = false
	$Goals/Red/Class/CollisionShape3D.disabled = false
	$Timer.process_mode = Node.PROCESS_MODE_DISABLED
	$DECODEOverlay/Timer.process_mode = Node.PROCESS_MODE_INHERIT
	$DECODEOverlay/Timer.start()
	$DECODEOverlay.countDown = false
	$DECODEOverlay/CenterContainer2/Label.text = ""


func _on_decode_overlay_match_finished() -> void:
	$Robot.process_mode = Node.PROCESS_MODE_DISABLED
	$Goals/Blue/Over/CollisionShape3D.disabled = true
	$Goals/Red/Over/CollisionShape3D.disabled = true
	$Goals/Blue/Class/CollisionShape3D.disabled = true
	$Goals/Red/Class/CollisionShape3D.disabled = true


func _on_blue_class_body_entered(body: Node3D) -> void:
	if body is Artifact and body.launchSource!=null:
		if body.launchZone and body.launchSource.alliance==0:
			$DECODEOverlay.scoreB += 2
		body.launchSource = null


func _on_red_class_body_entered(body: Node3D) -> void:
	if body is Artifact and body.launchSource!=null:
		if body.launchZone and body.launchSource.alliance==1:
			$DECODEOverlay.scoreR += 2
		body.launchSource = null


func _on_blue_gate_body_exited(body: Node3D) -> void:
	if body is Artifact:
		if blueGateOpener.alliance!=0:
			$DECODEOverlay.scoreB += 15


func _on_red_gate_body_exited(body: Node3D) -> void:
	if body is Artifact:
		if redGateOpener.alliance!=1:
			$DECODEOverlay.scoreR += 15
