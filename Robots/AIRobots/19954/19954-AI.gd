extends AIRobot


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

var nearestArtifact: Artifact = null
var nearestLaunch: Vector3
var inLaunch = true
var gatePosition: Vector3

func _ready() -> void:
	super()
	get_tree().root.get_node("/root/"+Global.field+"/LaunchZones/Far").body_entered.connect(enterLaunch)
	get_tree().root.get_node("/root/"+Global.field+"/LaunchZones/Close").body_entered.connect(enterLaunch)
	get_tree().root.get_node("/root/"+Global.field+"/LaunchZones/Far").body_exited.connect(exitLaunch)
	get_tree().root.get_node("/root/"+Global.field+"/LaunchZones/Close").body_exited.connect(exitLaunch)
	if alliance==0:
		$MeshInstance3D.mesh = load("res://Robots/19954/Meshes/BodyB.tres")
func _input(event: InputEvent) -> void:
	pass
func _process(delta: float) -> void:
	super(delta)
	updateTurret()
	dist = global_position.distance_to(targetPos)
	revTime = (0.3*(dist/40))
	
	$Turret.global_rotation.y = move_toward($Turret.global_rotation.y, -targetAng+rotation.y, turretSpeed)
	turretSpeed = move_toward(turretSpeed, 0.1, 0.03)
	if $Turret.global_rotation.y == -targetAng+rotation.y:
		turretSpeed = 0.03
	
	
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
		#print(vel)
		var fdir = global_position.direction_to($Forward.global_position)
		arti.apply_central_impulse(fdir*3.5)
		intakeArtifacts.remove_at(0)
func _physics_process(delta: float) -> void:
	if nav:
		shooting = false
		if inLaunch and not intakeArtifacts.is_empty() and dist>=15:
			shooting = true
			velocity = Vector3.ZERO
			input_dir = Vector2.ZERO
		elif intakeArtifacts.size()<3:
			nearestArtifact = null
			for i: Node3D in get_tree().root.get_node("/root/"+Global.field+"/Artifacts").get_children():
				if not i.get_node("Artifact").freeze and i.get_node("Artifact").visible:# and i.get_node("Artifact").position.y<0.6:
					if nearestArtifact==null or i.get_node("Artifact").global_position.distance_to(global_position)<nearestArtifact.global_position.distance_to(global_position):
						nearestArtifact = i.get_node("Artifact")
			if nearestArtifact.position.y>0.6:
				navPosition = gatePosition
			else:
				navPosition = nearestArtifact.global_position
				global_rotation.y = move_toward(global_rotation.y, -Vector2.ZERO.angle_to_point(input_dir)-deg_to_rad(90), 0.1)
				#global_rotation.y = -Vector2.ZERO.angle_to_point(input_dir)-deg_to_rad(90)
				intaking = true
		elif not inLaunch or global_position.distance_to(targetPos)<=15:
			intaking = false
			#$Far.target_position = $Far.to_local(get_tree().root.get_node("/root/"+Global.field+"/LaunchZones/Far").global_position)
			#$Close.target_position = $Close.to_local(get_tree().root.get_node("/root/"+Global.field+"/LaunchZones/Close").global_position)
			#if $Far.is_colliding() and $Close.is_colliding():
				#if global_position.distance_to($Far.get_collision_point())<global_position.distance_to($Close.get_collision_point()):
					#nearestLaunch = $Far.to_global($Far.get_collision_point())
					##print($Far.get_collision_point())
				#else:
					#nearestLaunch = $Close.to_global($Close.get_collision_point())
					##print($Close.get_collision_point())
			if global_position.distance_to(get_tree().root.get_node("/root/"+Global.field+"/LaunchZones/Far").global_position)<global_position.distance_to(get_tree().root.get_node("/root/"+Global.field+"/LaunchZones/Close").global_position):
				nearestLaunch = get_tree().root.get_node("/root/"+Global.field+"/LaunchZones/Far").global_position
			else:
				nearestLaunch = get_tree().root.get_node("/root/"+Global.field+"/LaunchZones/Close").global_position
			navPosition = nearestLaunch
		else:
			intaking = false
			nav = false
	else:
		nav = true
	if not shooting:
		input_dir = Vector2(global_position.direction_to(navPosition).x, global_position.direction_to(navPosition).z)
	#input_dir = Vector2(navAgent.get_next_path_position().x, navAgent.get_next_path_position().z)
	
	if not is_on_floor():
		velocity += 2*get_gravity() * delta
	
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
		#print(intakeArtifacts)
		collection.emit(intakeArtifacts)

func launch():
	if not intakeArtifacts.is_empty():
		launchAngle = 85*(0.98**dist)
		var a = launchAngle
		var arti = intakeArtifacts[0]
		
		arti.move_body($Turret/Out.global_position)
		var x = targetPos.distance_to($Turret/Out.global_position)
		var y = targetPos.y-$Turret/Out.global_position.y
		var vel := Vector3.ZERO
		#var a = rad_to_deg(abs(Vector2.RIGHT.angle_to(Vector2.ZERO.direction_to(Vector2(x, y)))))+50
		#print(a)
		#targetV = sqrt((dist*27.719)/sin(2*a))
		targetV = sqrt((27.719*(x**2))/(2*(cos(deg_to_rad(a))**2)*(x*tan(deg_to_rad(a))-y))+$Turret/Out.global_position.y)/2
		#print(v)
		vel.y = (sin(deg_to_rad(a)) * targetV)
		var turretDir := Vector2($Turret.global_position.x, $Turret.global_position.z).direction_to(Vector2($Turret/Out.global_position.x, $Turret/Out.global_position.z))
		vel.x = turretDir.x * (targetV*0.8)
		vel.z = turretDir.y * (targetV*0.8)
		
		arti.freeze = false
		arti.get_node("CollisionShape3D").disabled = false
		#print(vel)
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
