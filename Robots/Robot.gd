class_name Robot
extends CharacterBody3D

@export_enum("Blue", "Red") var alliance := 0
@onready var marker: Label3D = $Label3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if alliance==0:
		marker.modulate = "0000e2"
	else:
		marker.modulate = "ec0000"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	marker.look_at(get_node("/root/"+Global.field+"/Camera3D").global_position)
