class_name AIRobot
extends Robot

@onready var navAgent: NavigationAgent3D = $NavigationAgent3D
@export var navPosition: Vector3
var nav = true

signal collection(collected: Array)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
