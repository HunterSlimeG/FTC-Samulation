class_name Overlay
extends Node2D

var artifacts: Array[Artifact] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for a in range(3):
		if a<artifacts.size():
			match artifacts[a].color:
				0:
					$Artifacts.get_node(str(a)).modulate = "c72eff"
				1:
					$Artifacts.get_node(str(a)).modulate = "00e100"
			$Artifacts.get_node(str(a)).visible = true
		else:
			$Artifacts.get_node(str(a)).visible = false


func _on_button_pressed() -> void:
	owner.reload()
