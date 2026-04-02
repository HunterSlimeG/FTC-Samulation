extends Control

var robotDict: Dictionary[String, Array] = {
	"DECODE": [
		"19954"
	]
}

var field: Field
var robots: Array[Robot]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Start.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var progress = []
	if ResourceLoader.load_threaded_get_status("res://Fields/"+Global.field+"/"+Global.field+".scn", progress)==3:
		$Start.disabled = false
	$ProgressBar.value = move_toward($ProgressBar.value, progress[0]*100, delta * 20)

func _on_season_item_selected(index: int) -> void:
	var text = $Season.get_item_text(index)
	Global.field = field
	$Season.set_item_disabled(index, true)

func _on_start_pressed() -> void:
	ResourceLoader.load_threaded_request("res://Fields/"+Global.field+"/"+Global.field+".scn", "", true)
	
