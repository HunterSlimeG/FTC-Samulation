extends DriveRobot


const MAXSPEED = 10
var SPEED = 0
var push_force = 4.0
var input_dir := Vector2.ZERO
var turn := 0.0

var launchAngle: float = 45
var goal = "blue"
var targetPos: Vector3
var targetV: float
var dist: float

var shooting = false
var canShoot = true
var revTime = 0.25

var canOuttake = true
var outtaking = false
var intaking = false
var intakeArtifacts: Array[Artifact] = []

var inLaunch = true

func _ready() -> void:
	super()
	driverContexts[1].mappings[3].action.completed.connect(intakeUp)
	driverContexts[1].mappings[4].action.completed.connect(intakeDown)
	get_tree().root.get_node("/root/"+Global.field+"/LaunchZones/Far").body_entered.connect(enterLaunch)
	get_tree().root.get_node("/root/"+Global.field+"/LaunchZones/Close").body_entered.connect(enterLaunch)
	get_tree().root.get_node("/root/"+Global.field+"/LaunchZones/Far").body_exited.connect(exitLaunch)
	get_tree().root.get_node("/root/"+Global.field+"/LaunchZones/Close").body_exited.connect(exitLaunch)
	#if alliance==0:
		#$MeshInstance3D.mesh = load("res://Robots/DriveRobot/19954/Meshes/BodyB.tres")
func _process(delta: float) -> void:
	super(delta)
	shooting = driverContexts[1].mappings[2].action.value_bool
	dist = global_position.distance_to(targetPos)
	revTime = 1
	
	intaking = driverContexts[1].mappings[0].action.value_bool
	outtaking = driverContexts[1].mappings[1].action.value_bool
	
	$Area3D/CollisionShape3D.disabled = not intaking
	if shooting:
		if canShoot:
			canShoot = false
			launch(18)
			$ShotCool.start(revTime)
		
	if outtaking and intakeArtifacts.size()>0 and canOuttake:
		canOuttake = false
		$OutCool.start()
		var arti = intakeArtifacts[0]
		arti.move_body($Forward.global_position)
		
		arti.visible = true
		arti.freeze = false
		arti.get_node("CollisionShape3D").disabled = false

		var fdir = global_position.direction_to($Forward.global_position)
		arti.apply_central_impulse(fdir*5)
		intakeArtifacts.remove_at(0)
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += 2*get_gravity() * delta
	
	input_dir = driverContexts[0].mappings[0].action.value_axis_2d
	turn = -driverContexts[0].mappings[1].action.value_axis_1d
	
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	rotate(Vector3.UP, turn/14)
	if direction:
		SPEED = move_toward(SPEED, MAXSPEED, 0.4)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, MAXSPEED)
		velocity.z = move_toward(velocity.z, 0, MAXSPEED)
		SPEED = 0
		
	move_and_slide()
	#wheels()
	
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider(i) is Artifact:
			c.get_collider(i).apply_central_impulse(-c.get_normal(i) * (push_force*abs(direction)))
		elif c.get_collider(i) is Robot or c.get_collider(i) is AIRobot:
			c.get_collider(i).velocity = -c.get_normal(i) * (push_force*abs(direction))*4

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Artifact and intakeArtifacts.size()<3:
		body.visible = false
		body.freeze = true
		body.get_node("CollisionShape3D").disabled = true
		intakeArtifacts.append(body)
		collection.emit(intakeArtifacts)

func launch(v):
	if not intakeArtifacts.is_empty():
		launchAngle = 45
		var arti = intakeArtifacts[0]
		
		arti.move_body($Out.global_position)
		var x = targetPos.distance_to($Out.global_position)
		var y = targetPos.y-$Out.global_position.y
		var vel := Vector3.ZERO
		var turretDir := Vector2($FlyWheel.global_position.x, $FlyWheel.global_position.z).direction_to(Vector2($Out.global_position.x, $Out.global_position.z))
		vel.x = v*cos(deg_to_rad(launchAngle))*sin(-Vector2.DOWN.angle_to(turretDir))
		vel.y = sin(deg_to_rad(launchAngle)) * v
		vel.z = v*cos(deg_to_rad(launchAngle))*cos(-Vector2.DOWN.angle_to(turretDir))
		
		arti.launchSource = self
		arti.launchZone = inLaunch
		arti.freeze = false
		arti.get_node("CollisionShape3D").disabled = false
		arti.apply_central_impulse(vel+(velocity/6))
		arti.visible = true
		
		intakeArtifacts.remove_at(0)

func intakeUp():
	if intakeArtifacts.size()>=2:
		var lastArt = intakeArtifacts.pop_front()
		intakeArtifacts.push_back(lastArt)
func intakeDown():
	if intakeArtifacts.size()>=2:
		var lastArt = intakeArtifacts.pop_back()
		intakeArtifacts.push_front(lastArt)

func _on_shot_cool_timeout() -> void:
	canShoot = true
func _on_out_cool_timeout() -> void:
	canOuttake = true

func enterLaunch(body):
	if body==self:
		inLaunch = true
func exitLaunch(body):
	if body==self:
		inLaunch = false
