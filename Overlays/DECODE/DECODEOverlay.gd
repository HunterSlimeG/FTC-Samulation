extends Overlay

var artifactsB: Array[Artifact] = []
var artifactsR: Array[Artifact] = []
var scoreB: int = 0
var scoreR: int = 0
var countDown = true

var robotBlue: Robot
var robotRed: Robot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	robotBlue = get_node("/root/"+Global.field+"/Robot/B").get_child(0)
	robotRed = get_node("/root/"+Global.field+"/Robot/R").get_child(0)
	
	if robotBlue is DriveRobot:
		var formatBlue1: GUIDEInputFormatter = GUIDEInputFormatter.for_context(robotBlue.driverContexts[0])
		var formatBlue2: GUIDEInputFormatter = GUIDEInputFormatter.for_context(robotBlue.driverContexts[1])
		$ControlsB.text = robotBlue.name
		$ControlsB.append_text("\n[b]Controller "+str(robotBlue.driver1+1)+":[/b]")
		for m: GUIDEActionMapping in robotBlue.driverContexts[0].mappings:
			var action_text: String = await formatBlue1.action_as_richtext_async(m.action)
			$ControlsB.append_text("\n"+m.action.name+" - "+action_text)
		$ControlsB.append_text("\n[b]Controller "+str(robotBlue.driver2+1)+":[/b]")
		for m: GUIDEActionMapping in robotBlue.driverContexts[1].mappings:
			var action_text: String = await formatBlue2.action_as_richtext_async(m.action)
			$ControlsB.append_text("\n"+m.action.name+" - "+action_text)
	if robotRed is DriveRobot:
		var formatRed1: GUIDEInputFormatter = GUIDEInputFormatter.for_context(robotRed.driverContexts[0])
		var formatRed2: GUIDEInputFormatter = GUIDEInputFormatter.for_context(robotRed.driverContexts[1])
		$ControlsR.text = robotRed.name
		$ControlsR.append_text("\n[b]Controller "+str(robotRed.driver1+1)+":[/b]")
		for m: GUIDEActionMapping in robotRed.driverContexts[0].mappings:
			var action_text: String = await formatRed1.action_as_richtext_async(m.action)
			$ControlsR.append_text("\n"+m.action.name+" - "+action_text)
		$ControlsR.append_text("\n[b]Controller "+str(robotRed.driver2+1)+":[/b]")
		for m: GUIDEActionMapping in robotRed.driverContexts[1].mappings:
			var action_text: String = await formatRed2.action_as_richtext_async(m.action)
			$ControlsR.append_text("\n"+m.action.name+" - "+action_text)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if countDown:
		$CenterContainer2/Label.text = str(int(owner.get_node("Timer").time_left))
		$CenterContainer2/Label.visible = true
	$CenterContainer/Label.text = str(int($Timer.time_left)/60)+":"+str(int($Timer.time_left)%60).lpad(2, "0")




func _on_timer_timeout() -> void:
	if scoreB>scoreR:
		$CenterContainer2/Label.text = "Blue Wins!"
		$CenterContainer2/Label.modulate = "0000e2"
	else:
		$CenterContainer2/Label.text = "Red Wins!"
		$CenterContainer2/Label.modulate = "ec0000"
	$Timer.process_mode = Node.PROCESS_MODE_DISABLED
	$CenterContainer/Label.text = "0:00"
	#var hs := FileAccess.open("res://Fields/DECODE/HS.txt", FileAccess.READ_WRITE)
	#if scoreB>int(hs.get_as_text()) and scoreB>scoreR:
		#hs.store_string(str(scoreB))
	#if scoreR>int(hs.get_as_text()) and scoreR>scoreB:
		#hs.store_string(str(scoreR))
	matchFinished.emit()

func updateArtifacts(B:Array[Artifact], R:Array[Artifact]):
	artifactsB = B
	artifactsR = R
	$ArtifactsB/B.text = str(scoreB)
	$ArtifactsR/R.text = str(scoreR)
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
