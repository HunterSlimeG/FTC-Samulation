class_name AIRobot
extends Robot

@onready var navAgent: NavigationAgent3D = $NavigationAgent3D
var navPosition: Vector3
var navRotation: float
var nearRotation := true
var nav := true
enum navCases {NONE=-1, COLLECT=0, DELIVER=1}
var navCase = navCases.NONE

signal collection(collected: Array)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	
func _physics_process(delta: float) -> void:
	nearRotation = global_rotation.y>=navRotation-deg_to_rad(5) and global_rotation.y<=navRotation+deg_to_rad(5)
	if not nearRotation:
		#global_rotation.y = move_toward(global_rotation.y, navRotation, deg_to_rad(8))
		global_rotation.y = navRotation
