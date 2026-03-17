extends Robot


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

func _ready() -> void:
	super()
	if alliance==0:
		$MeshInstance3D.mesh = load("res://Robots/Patton/Meshes/BodyB.tres")
func _input(event: InputEvent) -> void:
	pass
func _process(delta: float) -> void:
	super(delta)
	shooting = driver2.mappings[11].action.value_bool
	updateTurret()
	dist = global_position.distance_to(targetPos)
	revTime = (0.3*(dist/40))
	
	$Turret.global_rotation.y = move_toward($Turret.global_rotation.y, -targetAng+rotation.y, turretSpeed)
	turretSpeed = move_toward(turretSpeed, 0.1, 0.03)
	if $Turret.global_rotation.y == -targetAng+rotation.y:
		turretSpeed = 0.03
	
	intaking = int(driver2.mappings[13].action.value_axis_1d)
	outtaking = int(driver2.mappings[12].action.value_axis_1d)
	
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
	if not is_on_floor():
		velocity += 2*get_gravity() * delta
		
	input_dir = driver1.mappings[0].action.value_axis_2d
	turn = -driver1.mappings[1].action.value_axis_2d.x
	
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
		elif c.get_collider(i) is Robot:
			c.get_collider(i).velocity = -c.get_normal(i) * (push_force*abs(direction))

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
		targetV = sqrt((24.5*(x**2))/(2*(cos(deg_to_rad(a))**2)*(x*tan(deg_to_rad(a))-y)))/2
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

func wheels():
	pass
	#$Wheels/FR.rotate_x(rad_to_deg(-velocity.x+velocity.y))
	#$Wheels/FL.rotate_x(rad_to_deg(velocity.x+velocity.y))
	#$Wheels/BR.rotate_x(rad_to_deg(velocity.x+velocity.y))
	#$Wheels/BL.rotate_x(rad_to_deg(-velocity.x+velocity.y))
