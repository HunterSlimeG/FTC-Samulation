extends DriveRobot


const MAXSPEED = 12
var SPEED = 0
var push_force = 4.0
var input_dir := Vector2.ZERO
var turn := 0.0

var launchAngle: float = 45
var goal = "blue"
var targetPos: Vector3
var targetDir: Vector2
var targetAng: float
var targetV: float
var dist: float

var turretSpeed = 0.03
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
	get_tree().root.get_node("/root/"+Global.field+"/LaunchZones/Far").body_entered.connect(enterLaunch)
	get_tree().root.get_node("/root/"+Global.field+"/LaunchZones/Close").body_entered.connect(enterLaunch)
	get_tree().root.get_node("/root/"+Global.field+"/LaunchZones/Far").body_exited.connect(exitLaunch)
	get_tree().root.get_node("/root/"+Global.field+"/LaunchZones/Close").body_exited.connect(exitLaunch)
	if alliance==0:
		$MeshInstance3D.mesh = load("res://Robots/DriveRobot/19954/Meshes/BodyB.tres")
func _input(event: InputEvent) -> void:
	pass
func _process(delta: float) -> void:
	super(delta)
	shooting = driverContexts[1].mappings[2].action.value_bool
	updateTurret()
	dist = global_position.distance_to(targetPos)
	revTime = (0.3*(dist/40))
	
	$Turret.global_rotation.y = move_toward($Turret.global_rotation.y, -targetAng+rotation.y, turretSpeed)
	turretSpeed = move_toward(turretSpeed, 0.1, 0.03)
	if $Turret.global_rotation.y == -targetAng+rotation.y:
		turretSpeed = 0.03
	
	intaking = driverContexts[1].mappings[0].action.value_bool
	outtaking = driverContexts[1].mappings[1].action.value_bool
	
	$Area3D/CollisionShape3D.disabled = not intaking
	if shooting:
		if canShoot:
			canShoot = false
			launch()
			$ShotCool.start(revTime)
		#elif $ShotCool.is_stopped():
		#	$ShotCool.start(revTime)
		
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

func launch():
	if not intakeArtifacts.is_empty():
		if dist>=15:
			launchAngle = clamp(85*(0.98**dist)-15, 30, 90)
		else:
			launchAngle = 70
		#launchAngle = 90
		var a = launchAngle
		var arti = intakeArtifacts[0]
		
		arti.move_body($Turret/Out.global_position)
		var x = targetPos.distance_to($Turret/Out.global_position)
		var y = targetPos.y-$Turret/Out.global_position.y
		var vel := Vector3.ZERO
		#var a = rad_to_deg(abs(Vector2.RIGHT.angle_to(Vector2.ZERO.direction_to(Vector2(x, y)))))+50
		#targetV = sqrt((dist*abs(get_gravity().y))/sin(2*a))/2
		#    (abs(get_gravity().y)/8)
		targetV = sqrt((abs(get_gravity().y)*(x**2))/(2*(cos(deg_to_rad(a))**2)*(x*tan(deg_to_rad(a))-y))+($Turret/Out.global_position.y))/1.5
		#targetV = sqrt(((abs(get_gravity().y)/4)*(x**2))/(2*(cos(deg_to_rad(a))**2)*(x*tan(deg_to_rad(a))-y))+($Turret/Out.global_position.y))
		var turretDir := Vector2($Turret.global_position.x, $Turret.global_position.z).direction_to(Vector2($Turret/Out.global_position.x, $Turret/Out.global_position.z))
		vel.x = targetV*cos(deg_to_rad(a))*sin(-Vector2.DOWN.angle_to(turretDir))
		vel.y = sin(deg_to_rad(a)) * targetV
		vel.z = targetV*cos(deg_to_rad(a))*cos(-Vector2.DOWN.angle_to(turretDir))
		
		arti.launchSource = self
		arti.launchZone = inLaunch
		arti.freeze = false
		arti.get_node("CollisionShape3D").disabled = false
		arti.apply_central_impulse(vel+(velocity/6))
		arti.visible = true
		
		intakeArtifacts.remove_at(0)
func updateTurret():
	var fDir := Vector2(global_position.x, global_position.z).direction_to(Vector2($Forward.global_position.x, $Forward.global_position.z))
	var tDir := Vector2(global_position.x, global_position.z).direction_to(Vector2(targetPos.x, targetPos.z))
	targetAng = fDir.angle_to(tDir)
	targetDir = tDir

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
