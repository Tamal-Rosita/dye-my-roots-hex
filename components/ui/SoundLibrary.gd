extends Control

signal back

# Dev "sound test": browse and play the whole audio library.
#   UP/DOWN  -> move through the list
#   A/ENTER  -> play the highlighted entry
#   B/CANCEL -> back to the main menu
#
# Lists every procedural sound from the Sfx bank plus every file-based track
# used in the game (with its embedded metadata: title/artist/album/source).

const FILE_TRACKS: Array = [
	{
		"name": "Funky Groove (music)",
		"path": "res://sounds/566952__code_box__funky-groove.wav",
		"title": "Funky Groove",
		"artist": "code_box",
		"album": "Freesound",
		"source": "https://freesound.org/people/code_box/sounds/566952/",
		"used": "Main scene BGM"
	},
	{
		"name": "Cash Register",
		"path": "res://sounds/201159__kiddpark__cash-register.mp3",
		"title": "Cash Register",
		"artist": "kiddpark",
		"album": "Freesound",
		"source": "https://freesound.org/people/kiddpark/sounds/201159/",
		"used": "Round won (cash)"
	},
	{
		"name": "Cashier Receipt Servo",
		"path": "res://sounds/91920__filipe-chagas__cashierreceiptservo.wav",
		"title": "Cashier Receipt Servo",
		"artist": "filipe-chagas",
		"album": "Freesound",
		"source": "https://freesound.org/people/filipe-chagas/sounds/91920/",
		"used": "Round won (money)"
	},
	{
		"name": "Wrong (unused)",
		"path": "res://sounds/483598__raclure__wrong.mp3",
		"title": "Wrong",
		"artist": "raclure",
		"album": "Freesound",
		"source": "https://freesound.org/people/raclure/sounds/483598/",
		"used": "Unused (replaced by procedural 'denied')"
	},
	{
		"name": "Timeout (unused)",
		"path": "res://sounds/Timeout.wav",
		"title": "Timeout",
		"artist": "Unknown",
		"album": "",
		"source": "",
		"used": "Unused (replaced by procedural 'fail')"
	}
]

export(Color) var selected_color: Color = Color(0.886, 0.702, 0.835)
export(Color) var normal_color: Color = Color(0.9, 0.9, 0.9, 0.8)
export(float) var row_height: float = 26.0

var entries: Array = []
var selected: int = 0
var labels: Array = []
var input_enabled: bool = true
var file_player: AudioStreamPlayer

func set_input_enabled(value: bool):
	input_enabled = value

func _ready():
	file_player = AudioStreamPlayer.new()
	add_child(file_player)
	_build_entries()
	_build_labels()
	_refresh()

func _build_entries():
	var sfx_names: Array = Sfx.sounds.keys()
	sfx_names.sort()
	for name in sfx_names:
		entries.append({"kind": "sfx", "name": name, "label": "SFX  " + name})
	for track in FILE_TRACKS:
		entries.append({"kind": "file", "name": track["name"], "path": track["path"], "meta": track, "label": "FILE " + track["name"]})

func _build_labels():
	var font_data = load("res://fonts/rainyhearts.ttf")
	var font: DynamicFont = DynamicFont.new()
	if font_data:
		font.font_data = font_data
	font.size = 20
	for i in range(entries.size()):
		var label: Label = Label.new()
		label.add_font_override("font", font)
		label.anchor_left = 0.0
		label.anchor_right = 1.0
		label.margin_top = 74.0 + i * row_height
		label.margin_bottom = label.margin_top + row_height - 4.0
		labels.append(label)
		add_child(label)
	$Details.add_font_override("font", font)

func _refresh():
	for i in range(labels.size()):
		var label: Label = labels[i]
		var marker: String = "> " if i == selected else "  "
		label.text = marker + entries[i]["label"]
		label.add_color_override("font_color", selected_color if i == selected else normal_color)
	_update_details()

func _update_details():
	var entry: Dictionary = entries[selected]
	if entry["kind"] == "sfx":
		$Details.text = "Sfx.play(\"%s\")  —  synthesized procedural tone(s)" % entry["name"]
	else:
		var m: Dictionary = entry["meta"]
		$Details.text = "\"%s\" by %s  [%s]  —  used: %s" % [m["title"], m["artist"], m["album"], m["used"]]
		if m["source"] != "":
			$Details.text += "  —  " + m["source"]

func _process(_delta):
	if not is_visible_in_tree() or not input_enabled:
		return
	if Input.is_action_just_pressed("ui_up"):
		_selection(-1)
	if Input.is_action_just_pressed("ui_down"):
		_selection(1)
	if Input.is_action_just_pressed("ui_accept"):
		# Sfx.play("confirm")
		_activate()
	if Input.is_action_just_pressed("ui_cancel"):
		Sfx.play("cancel")
		emit_signal("back")

func _selection(dir):
	selected = (selected + dir + entries.size()) % entries.size()
	_refresh()
	Sfx.play("select")

func _activate():
	var entry: Dictionary = entries[selected]
	if entry["kind"] == "sfx":
		Sfx.play(entry["name"])
	else:
		file_player.stop()
		var stream = load(entry["path"])
		if stream:
			file_player.stream = stream
			file_player.play()
