extends Overlay

var artifactsB: Array[Artifact] = []
var artifactsR: Array[Artifact] = []
var scoreB: int = 0
var scoreR: int = 0
var countDown = true
#var formatter:GUIDEInputFormatter = GUIDEInputFormatter.for_context(Global.drivers[0])

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#$RichLabel.text = "Driver 1: \n"
	#$RichLabel.append_text(tr("Use %s to [b]Move[/b]\n") % [await formatter.action_as_richtext_async(Global.drivers[0].mappings[0].action)])
	#$RichLabel.append_text(tr("Use %s to [b]Turn[/b]\n") % [await formatter.action_as_richtext_async(Global.drivers[0].mappings[1].action)])
	#$RichLabel.append_text("\n Driver 2: \n")
	#$RichLabel.append_text(tr("Hold %s to [b]Intake[/b]\n") % [await formatter.action_as_richtext_async(Global.drivers[0].mappings[13].action)])
	#$RichLabel.append_text(tr("Hold %s to [b]Outtake[/b]\n") % [await formatter.action_as_richtext_async(Global.drivers[0].mappings[12].action)])
	#$RichLabel.append_text(tr("Press %s to [b]Launch[/b]\n") % [await formatter.action_as_richtext_async(Global.drivers[0].mappings[11].action)])
	#$RichLabel.append_text("\n Any: \n")
	#$RichLabel.append_text(tr("Press %s to [b]Reset Field[/b]\n") % [await formatter.action_as_richtext_async(Global.drivers[0].mappings[15].action)])
	#$RichLabel.append_text(tr("Press %s to [b]Switch Cameras[/b]\n") % [await formatter.action_as_richtext_async(Global.drivers[0].mappings[14].action)])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if countDown:
		$CenterContainer2/Label.text = str(int(owner.get_node("Timer").time_left))
		$CenterContainer2/Label.visible = true
	else:
		$CenterContainer2/Label.visible = false
	$CenterContainer/Label.text = str(int($Timer.time_left)/60)+":"+str(int($Timer.time_left)%60).lpad(2, "0")




func _on_timer_timeout() -> void:
	$Timer.process_mode = Node.PROCESS_MODE_DISABLED
	$CenterContainer/Label.text = "0:00"
	var hs := FileAccess.open("res://Fields/DECODE/HS.txt", FileAccess.READ_WRITE)
	if scoreB>int(hs.get_as_text()) and scoreB>scoreR:
		hs.store_string(str(scoreB))
	if scoreR>int(hs.get_as_text()) and scoreR>scoreB:
		hs.store_string(str(scoreR))
	matchFinished.emit()

func updateArtifacts(B:Array[Artifact], R:Array[Artifact]):
	artifactsB = B
	artifactsR = R
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
