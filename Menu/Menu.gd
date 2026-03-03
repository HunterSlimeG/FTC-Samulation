extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ResourceLoader.load_threaded_get_status("res://Fields/"+Global.field+"/"+Global.field+".scn")==3:
		get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get("res://Fields/"+Global.field+"/"+Global.field+".scn"))


func _on_item_list_item_activated(index: int) -> void:
	var text = $ItemList.get_item_text(index)
	Global.field = text
	ResourceLoader.load_threaded_request("res://Fields/"+text+"/"+text+".scn", "", true)
	$ItemList.set_item_disabled(index, true)
