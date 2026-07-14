extends Node2D

var con: Node

@export var active = false
@export var device = 0

var frames: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match device:
		1:
			$MeshInstance2D.modulate = Color(0, 0, 1)
		2:
			$MeshInstance2D.modulate = Color(1, 0, 0)
		3:
			$MeshInstance2D.modulate = Color(0, 1, 0)
		4:
			$MeshInstance2D.modulate = Color(1, 0, 1)
	$Label.text = str(device)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position+=Global.cursorContexts[device-1].mappings[1].action.value_axis_2d*500*delta
	frames += 1
	if frames%30==0:
		con = self
		for i in get_all_selectables(owner):
			if i.get_global_rect().has_point(global_position) and i.visible and i.get_parent().visible and (not i is Panel and not i is Label and (not i is Container or i is TabContainer)):
				con = i
				$Panel.visible = true
				$Panel.global_position = con.get_global_rect().position
				$Panel.size = con.get_global_rect().size
				break
		if con==self:
			$Panel.visible = false

func _input(event: InputEvent) -> void:
	if not Global.cursorContexts[device-1].mappings[1].action.value_axis_2d.is_zero_approx() and not active:
		active = true
		visible = true
		
	if Global.cursorContexts[device-1].mappings[0].action.is_triggered() and active:
		if con!=self:
			if con is CheckBox:
				if con.button_pressed:
					con.pressed.emit()
					con.button_pressed = false
				else:
					con.pressed.emit()
					con.button_pressed = true
				con = self
			elif con is ItemList:
				var pos = Vector2(position.x, position.y-40)-con.position
				var it: int = con.get_item_at_position(pos, false)
				if not con.is_selected(it) and it>-1:
					con.select(it)
					con.item_selected.emit(it)
				con = self
			elif con is OptionButton and not con.get_popup().visible:
				con.show_popup()
				await con.item_selected
				con = self
			elif con is Button:
				con.pressed.emit()
				con = self
			elif con is TabContainer:
				print(con.current_tab)
				con.current_tab = con.get_tab_idx_at_point(global_position)
				con = self

func get_all_selectables(node: Node):
	var nodes : Array = []
	for N in node.get_children():
		if N is Control:
			nodes.append(N)
		if N.get_child_count() > 0:
			nodes.append_array(get_all_selectables(N))
	return nodes
