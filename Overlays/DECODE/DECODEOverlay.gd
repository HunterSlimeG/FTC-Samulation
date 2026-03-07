extends Overlay

var artifactsB: Array[Artifact] = []
var artifactsR: Array[Artifact] = []
var scoreB: int = 0
var scoreR: int = 0
var countDown = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if countDown:
		$CenterContainer2/Label.text = str(int(owner.get_node("Timer").time_left))
		$CenterContainer2/Label.visible = true
	else:
		$CenterContainer2/Label.visible = false
	$CenterContainer/Label.text = str(int($Timer.time_left)/60)+":"+str(int($Timer.time_left)%60).lpad(2, "0")
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




func _on_timer_timeout() -> void:
	$Timer.process_mode = Node.PROCESS_MODE_DISABLED
	$CenterContainer/Label.text = "0:00"
	owner.get_node("Robot").process_mode = Node.PROCESS_MODE_DISABLED
	$ArtifactsB/B.process_mode = Node.PROCESS_MODE_DISABLED
	$ArtifactsR/R.process_mode = Node.PROCESS_MODE_DISABLED
	var hs := FileAccess.open("res://Fields/DECODE/HS.txt", FileAccess.READ_WRITE)
	if scoreB>int(hs.get_as_text()) and scoreB>scoreR:
		hs.store_string(str(scoreB))
	if scoreR>int(hs.get_as_text()) and scoreR>scoreB:
		hs.store_string(str(scoreR))
