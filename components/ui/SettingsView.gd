extends Control

signal back

# Volume settings, persisted through SaveSystem and applied to the audio
# buses (Master/SFX/Music) by Sfx.apply_volumes().
#   UP/DOWN   -> pick a row
#   LEFT/RIGHT-> adjust the volume in 5% steps
#   B/CANCEL  -> back

const ROWS: Array = [
	{"label": "MASTER", "key": "master"},
	{"label": "EFFECTS", "key": "sfx"},
	{"label": "MUSIC", "key": "music"}
]

export(Color) var selected_color: Color = Color(0.886, 0.702, 0.835)
export(Color) var normal_color: Color = Color(0.9, 0.9, 0.9)
export(float) var row_height: float = 52.0
export(int) var step_percent: int = 5

var selected: int = 0
var labels: Array = []
var input_enabled: bool = true

func set_input_enabled(value: bool):
	input_enabled = value

func _ready():
	_build_labels()
	_refresh()

func _build_labels():
	for i in range(ROWS.size()):
		var label: Label = Label.new()
		label.align = Label.ALIGN_CENTER
		label.valign = Label.VALIGN_CENTER
		label.anchor_left = 0.0
		label.anchor_right = 1.0
		label.margin_top = i * row_height
		label.margin_bottom = i * row_height + row_height - 12.0
		labels.append(label)
		$Panel/Rows.add_child(label)

func _refresh():
	for i in range(labels.size()):
		var row: Dictionary = ROWS[i]
		var percent: int = int(round(SaveSystem.get_setting(row["key"]) * 100.0))
		var marker: String = "> " if i == selected else "  "
		labels[i].text = "%s%s  %d%%" % [marker, row["label"], percent]
		labels[i].add_color_override("font_color", selected_color if i == selected else normal_color)

func _process(_delta):
	if not is_visible_in_tree() or not input_enabled:
		return
	if Input.is_action_just_pressed("ui_up"):
		selected = (selected - 1 + ROWS.size()) % ROWS.size()
		Sfx.play("select")
		_refresh()
	if Input.is_action_just_pressed("ui_down"):
		selected = (selected + 1) % ROWS.size()
		Sfx.play("select")
		_refresh()
	if Input.is_action_just_pressed("ui_left"):
		_adjust(-float(step_percent) / 100.0)
	if Input.is_action_just_pressed("ui_right"):
		_adjust(float(step_percent) / 100.0)
	if Input.is_action_just_pressed("ui_cancel"):
		Sfx.play("cancel")
		emit_signal("back")

func _adjust(delta: float):
	var row: Dictionary = ROWS[selected]
	var value: float = SaveSystem.get_setting(row["key"])
	value = stepify(clamp(value + delta, 0.0, 1.0), 0.05)
	SaveSystem.set_setting(row["key"], value)
	Sfx.play("tick")
	_refresh()
