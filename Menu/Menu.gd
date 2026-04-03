extends Control

var robotDict: Dictionary[String, Array] = {
	"DECODE": [
		"19954"
	]
}

var field: Field
var robots: Array[String] = ["", ""]
var blueDrivers: Array[int] = [1, 1]
var redDrivers: Array[int] = [2, 2]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Season.grab_focus()
	$CenterContainer/Version.text = "v"+ProjectSettings.get_setting("application/config/version")
	$"CenterContainer2/Update-Patch".uri = "https://github.com/HunterSlimeG/FTC-Samulation/releases/tag/EXPLORE-Current"
	#$HTTPRequest.request("https://api.github.com/repos/HunterSlimeG/FTC-Samulation/releases/latest")
	print($HTTPRequest.download_file)
	$Start.disabled = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var progress = []
	if robots[0]!="" and robots[1]!="":
		$Start.disabled = false
	if ResourceLoader.load_threaded_get_status("res://Fields/"+Global.field+"/"+Global.field+".scn", progress)==3:
		var fieldLoaded: Node3D = ResourceLoader.load_threaded_get("res://Fields/"+Global.field+"/"+Global.field+".scn").instantiate()
		var robotBlue: Robot
		if blueDrivers[0]>0 and blueDrivers[1]>0:
			robotBlue = load("res://Robots/DriveRobot/"+robots[0]+"/"+robots[0]+".tscn").instantiate()
			robotBlue.driver1 = blueDrivers[0]-1
			robotBlue.driver2 = blueDrivers[1]-1
		else:
			robotBlue = load("res://Robots/AIRobots/"+robots[0]+"/"+robots[0]+"-AI.tscn").instantiate()
		var robotRed: Robot
		if redDrivers[0]>0 and redDrivers[1]>0:
			robotRed = load("res://Robots/DriveRobot/"+robots[1]+"/"+robots[1]+".tscn").instantiate()
			robotRed.driver1 = redDrivers[0]-1
			robotRed.driver2 = redDrivers[1]-1
		else:
			robotRed = load("res://Robots/AIRobots/"+robots[1]+"/"+robots[1]+"-AI.tscn").instantiate()
		
		robotBlue.alliance = 0
		robotRed.alliance = 1
		fieldLoaded.get_node("Robot/B").add_child(robotBlue)
		fieldLoaded.get_node("Robot/R").add_child(robotRed)
		get_tree().change_scene_to_node(fieldLoaded)
	$ProgressBar.value = move_toward($ProgressBar.value, progress[0]*100, delta * 20)

func _on_season_item_selected(index: int) -> void:
	var text = $Season.get_item_text(index)
	Global.field = text
	for i in robotDict[text]:
		$RobotBlue.add_item(i)
		$RobotRed.add_item(i)
	

func _on_start_pressed() -> void:
	ResourceLoader.load_threaded_request("res://Fields/"+Global.field+"/"+Global.field+".scn", "", true)


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var currentVers = []
	for i in ProjectSettings.get_setting("application/config/version").split("."):
		currentVers.append(int(i))
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	var latestVers = []
	for i in response["name"].split("."):
		latestVers.append(int(i))
	
	if currentVers[0]<latestVers[0]:
		$"CenterContainer2/Update-Patch".text = "Update Available!"
	elif currentVers[0]==latestVers[0] and currentVers[1]<latestVers[1]:
		$"CenterContainer2/Update-Patch".text = "Update Available!"
	elif currentVers[0]==latestVers[0] and currentVers[1]==latestVers[1] and currentVers[2]<latestVers[2]:
		$"CenterContainer2/Update-Patch".text = "Update Available!"
	else:
		$"CenterContainer2/Update-Patch".text = "Patch Notes"


func _on_robot_blue_item_selected(index: int) -> void:
	robots[0] = $RobotBlue.get_item_text(index)

func _on_robot_red_item_selected(index: int) -> void:
	robots[1] = $RobotRed.get_item_text(index)


func _on_r_dr_1_item_selected(index: int) -> void:
	redDrivers[0] = index

func _on_r_dr_2_item_selected(index: int) -> void:
	redDrivers[1] = index

func _on_b_dr_1_item_selected(index: int) -> void:
	blueDrivers[0] = index

func _on_b_dr_2_item_selected(index: int) -> void:
	blueDrivers[1] = index
