extends Node2D

var con: Node

@export var active = true
@export var device = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	exit()
	for b in get_all_selectables(owner):
		if b.has_signal("mouse_entered") and b.has_signal("mouse_exited"):
			b.mouse_entered.connect(enter.bind(b))
			b.mouse_exited.connect(exit.bind(b))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		global_position = get_global_mouse_position()
		visible = true
		active = true
		
	if event.is_action_pressed("Click") and not event is InputEventMouseButton and active:
		if con!=self:
			if con is CheckBox:
				if con.button_pressed:
					con.pressed.emit()
					con.button_pressed = false
				else:
					con.pressed.emit()
					con.button_pressed = true
			elif con is OptionButton:
				con.show_popup()
			elif con is Button:
				con.pressed.emit()

func enter(node = self):
	con = node
	print(con)

func exit(node = self):
	con = self

func get_all_selectables(node: Node):
	var nodes : Array = []
	for N in node.get_children():
		if N is Button:
			nodes.append(N)
		if N.get_child_count() > 0:
			nodes.append_array(get_all_selectables(N))
	return nodes
