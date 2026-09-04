extends Control

signal option_selected(index)
signal cancelled

# Simple arcade menu: UP/DOWN (or mouse) to move, A/ENTER / left-click to
# activate. Options are shown as labels; the selected one is highlighted.

export(Array, String) var options: Array = ["Start Game", "High Scores", "Credits", "Extras"]
export(Color) var selected_color: Color = Color(0.886, 0.702, 0.835)
export(Color) var normal_color: Color = Color(0.9, 0.9, 0.9)
export(float) var row_height: float = 56.0

var selected: int = 0
var labels: Array = []
var input_enabled: bool = true

func _ready():
	_build_labels()
	_refresh()

func set_input_enabled(value: bool):
	input_enabled = value

func _build_labels():
	for i in range(options.size()):
		var label: Label = Label.new()
		label.align = Label.ALIGN_CENTER
		label.valign = Label.VALIGN_CENTER
		label.anchor_left = 0.0
		label.anchor_right = 1.0
		label.margin_top = i * row_height
		label.margin_bottom = i * row_height + row_height - 12.0
		label.mouse_filter = Control.MOUSE_FILTER_STOP
		label.connect("gui_input", self, "_on_label_gui_input", [i])
		label.connect("mouse_entered", self, "_on_label_mouse_entered", [i])
		labels.append(label)
		add_child(label)

func _refresh():
	for i in range(labels.size()):
		var label: Label = labels[i]
		if i == selected:
			label.add_color_override("font_color", selected_color)
			label.text = "> " + options[i] + " <"
		else:
			label.add_color_override("font_color", normal_color)
			label.text = "  " + options[i]

func _process(_delta):
	if not is_visible_in_tree() or not input_enabled:
		return
	if Input.is_action_just_pressed("ui_up"):
		_selection(-1)
	if Input.is_action_just_pressed("ui_down"):
		_selection(1)
	if Input.is_action_just_pressed("ui_accept"):
		_activate(selected)
	if Input.is_action_just_pressed("ui_cancel"):
		Sfx.play("cancel")
		emit_signal("cancelled")

func _selection(dir):
	selected = (selected + dir + options.size()) % options.size()
	_refresh()
	Sfx.play("select")

func _activate(index):
	Sfx.play("confirm")
	emit_signal("option_selected", index)

# Mouse support (mainly for desktop testing).
func _on_label_gui_input(event, index):
	if not is_visible_in_tree() or not input_enabled:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		selected = index
		_refresh()
		_activate(index)

func _on_label_mouse_entered(index):
	if not is_visible_in_tree() or not input_enabled:
		return
	if selected != index:
		selected = index
		_refresh()
		Sfx.play("select")
