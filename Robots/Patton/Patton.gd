extends Robot


const MAXSPEED = 10
var SPEED = 0
var push_force = 4.0
var input_dir := Vector2.ZERO
var turn := 0.0

@export var launchAngle: float = 45
var targetPos: Vector3
var targetDir: Vector2

var intaking = false
var intakeArtifacts: Array[Artifact] = []

func _input(event: InputEvent) -> void:
	if event.device==1 or event is InputEventKey or Input.get_joy_name(1)!="":
		if event.is_action_pressed("R1"):
			var dist = global_position.distance_to(targetPos)
			print(dist)
			launchAngle = 80.7499*(0.979253**dist)
			launch(launchAngle)
func _process(delta: float) -> void:
	targetDir = updateTurret()
	if Input.get_joy_name(1)!="":
		intaking = int(Input.get_joy_axis(1, JoyAxis.JOY_AXIS_TRIGGER_RIGHT))
	else:
		intaking = Input.is_action_pressed("R2")
	$Area3D/CollisionShape3D.disabled = not intaking
		
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * (delta*2)
		
	if Input.get_joy_name(0)!="":
		input_dir = snapped(Vector2(Input.get_joy_axis(0, JoyAxis.JOY_AXIS_LEFT_X), Input.get_joy_axis(0, JoyAxis.JOY_AXIS_LEFT_Y)), Vector2(0.2, 0.2))
		turn = -snapped(Input.get_joy_axis(0, JoyAxis.JOY_AXIS_RIGHT_X), 0.1)
	else:
		input_dir = Input.get_vector("LLeft", "LRight", "LUp", "LDown")
		turn = -Input.get_axis("RLeft", "RRight")
	
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	rotate(Vector3.UP, turn/12)
	if direction:
		SPEED = move_toward(SPEED, MAXSPEED, 1)
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

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Artifact and intakeArtifacts.size()<3:
		body.visible = false
		body.freeze = true
		body.get_node("CollisionShape3D").disabled = true
		intakeArtifacts.append(body)
		#print(intakeArtifacts)

func launch(a):
	if not intakeArtifacts.is_empty():
		var arti = intakeArtifacts[0]
		
		arti.move_body($Turret/Out.global_position)
		var x = targetPos.distance_to($Turret/Out.global_position)
		var y = targetPos.y-$Turret/Out.global_position.y
		var vel := Vector3.ZERO
		#var a = rad_to_deg(abs(Vector2.RIGHT.angle_to(Vector2.ZERO.direction_to(Vector2(x, y)))))+50
		#print(a)
		var v = sqrt((24.5*(x**2))/(2*(cos(deg_to_rad(a))**2)*(x*tan(deg_to_rad(a))-y)))/2
		#print(v)
		vel.y = sin(deg_to_rad(a)) * v
		vel.x = targetDir.x * (v*0.8)
		vel.z = targetDir.y * (v*0.8)
		
		arti.visible = true
		arti.freeze = false
		arti.get_node("CollisionShape3D").disabled = false
		#print(vel)
		arti.apply_central_impulse(vel)
		
		intakeArtifacts.remove_at(0)

func updateTurret() -> Vector2:
	var fDir := Vector2(global_position.x, global_position.z).direction_to(Vector2($Forward.global_position.x, $Forward.global_position.z))
	var tDir := Vector2(global_position.x, global_position.z).direction_to(Vector2(targetPos.x, targetPos.z))
	var ang = fDir.angle_to(tDir)
	
	$Turret.global_rotation.y = -ang+rotation.y
	return tDir
