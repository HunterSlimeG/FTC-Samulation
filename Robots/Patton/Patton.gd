extends Robot


const SPEED = 5.0
var push_force = 4.0
var input_dir := Vector2.ZERO
var turn := 0.0

var intaking = false
var intakeArtifacts: Array[Artifact] = []

func _process(delta: float) -> void:
	intaking = int(Input.get_joy_axis(1, JoyAxis.JOY_AXIS_TRIGGER_RIGHT))
	$Area3D/CollisionShape3D.disabled = not intaking
		
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * (delta*2)
		
	input_dir = snapped(Vector2(Input.get_joy_axis(0, JoyAxis.JOY_AXIS_LEFT_X), Input.get_joy_axis(0, JoyAxis.JOY_AXIS_LEFT_Y)), Vector2(0.2, 0.2))
	#print(input_dir)
	turn = -snapped(Input.get_joy_axis(0, JoyAxis.JOY_AXIS_RIGHT_X), 0.1)
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	rotate(Vector3.UP, turn/12)
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
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
		print(intakeArtifacts)

func launch(v, a):
	var arti = intakeArtifacts[0]
	
	arti.global_position = $Turret/Out.global_position
	var vel := Vector3.ZERO
	vel.y = -sin(deg_to_rad(a)) * v
	vel.x = v
	
	arti.apply_central_impulse(velocity)
	arti.visible = false
	arti.freeze = true
	arti.get_node("CollisionShape3D").disabled = true
	
	intakeArtifacts.remove_at(0)
