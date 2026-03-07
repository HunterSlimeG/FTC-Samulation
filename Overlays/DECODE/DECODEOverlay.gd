extends Overlay

var artifactsB: Array[Artifact] = []
var artifactsR: Array[Artifact] = []
var scoreB: int = 0
var scoreR: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$ArtifactsB/B.text = "Artifacts Scored: "+str(scoreB)
	$ArtifactsR/R.text = "Artifacts Scored: "+str(scoreR)
	for a in range(3):
		if a<artifactsB.size():
			match artifactsB[a].color:
				0:
					$ArtifactsB.get_node(str(a)).modulate = "c72eff"
				1:
					$ArtifactsB.get_node(str(a)).modulate = "00e100"
			#$Artifacts.get_node(str(a)).visible = true
		else:
			$ArtifactsB.get_node(str(a)).modulate = "cacaca"
	for a in range(3):
		if a<artifactsR.size():
			match artifactsR[a].color:
				0:
					$ArtifactsR.get_node(str(a)).modulate = "c72eff"
				1:
					$ArtifactsR.get_node(str(a)).modulate = "00e100"
			#$Artifacts.get_node(str(a)).visible = true
		else:
			$ArtifactsR.get_node(str(a)).modulate = "cacaca"


func _on_button_pressed() -> void:
	owner.reload()
