extends Node2D

var con: Node

@export var active = true
@export var device = 0

var frames: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label.text = str(device)
	exit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position+=Global.cursorContexts[device-1].mappings[1].action.value_axis_2d*500*delta
	frames += 1
	if frames%60==0:
		for i in get_all_selectables(owner):
			if i.get_global_rect().has_point(global_position) and i.visible:
				con = i
				con.grab_focus()
				print(con)
				break

func _input(event: InputEvent) -> void:
	if Global.cursorContexts[device-1].mappings[0].action.value_bool and active:
		if con!=self:
			if con is CheckBox:
				if con.button_pressed:
					con.pressed.emit()
					con.button_pressed = false
				else:
					con.pressed.emit()
					con.button_pressed = true
			elif con is ItemList:
				var it: int = con.get_item_at_position(global_position, true)
				if not con.is_selected(it):
					con.select(it)
					con.item_selected.emit(it)
			elif con is OptionButton:
				con.show_popup()
			elif con is Button:
				con.pressed.emit()

func enter(node):
	con = node.get_parent()
	print(con)

func exit(node = self):
	con = self

func get_all_selectables(node: Node):
	var nodes : Array = []
	for N in node.get_children():
		if N is Control:
			nodes.append(N)
		if N.get_child_count() > 0:
			nodes.append_array(get_all_selectables(N))
	return nodes
