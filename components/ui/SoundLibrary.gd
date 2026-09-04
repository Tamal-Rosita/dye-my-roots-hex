extends Control

signal back

# Dev "sound test": browse and play the whole audio library.
# Layout: list of sounds/tracks in the LEFT panel, description of the
# selected entry in the RIGHT panel.
#   UP/DOWN  -> move through the list
#   A/ENTER  -> play the highlighted entry
#   B/CANCEL -> back to the Extras menu

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
export(Color) var normal_color: Color = Color(0.9, 0.9, 0.9, 0.85)
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
	file_player.bus = "Master"
	add_child(file_player)
	_build_entries()
	_refresh_list()
	_update_details()

func _make_font(size: int) -> DynamicFont:
	var font_data = load("res://fonts/rainyhearts.ttf")
	var font: DynamicFont = DynamicFont.new()
	if font_data:
		font.font_data = font_data
	font.size = size
	return font

func _build_entries():
	var sfx_names: Array = Sfx.sounds.keys()
	sfx_names.sort()
	var row_font: DynamicFont = _make_font(20)
	$LeftPanel/LeftTitle.add_font_override("font", row_font)
	for name in sfx_names:
		entries.append({"kind": "sfx", "name": name, "label": "SFX  " + name})
	for track in FILE_TRACKS:
		entries.append({"kind": "file", "name": track["name"], "path": track["path"], "meta": track, "label": "FILE " + track["name"]})
	var list: VBoxContainer = $LeftPanel/Scroll/ListVBox
	for i in range(entries.size()):
		var label: Label = Label.new()
		label.add_font_override("font", row_font)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.rect_min_size = Vector2(0, row_height)
		list.add_child(label)
		labels.append(label)

func _refresh_list():
	for i in range(labels.size()):
		var label: Label = labels[i]
		var marker: String = "> " if i == selected else "  "
		label.text = marker + entries[i]["label"]
		label.add_color_override("font_color", selected_color if i == selected else normal_color)

# Keeps the highlighted row in sight: auto-scrolls the list when the
# selection moves out of the visible area (gamepad/keyboard navigation).
func _ensure_selection_visible():
	if selected < 0 or selected >= labels.size():
		return
	var scroll: ScrollContainer = $LeftPanel/Scroll
	scroll.ensure_control_visible(labels[selected])

func _update_details():
	var entry: Dictionary = entries[selected]
	if entry["kind"] == "sfx":
		$RightPanel/NameLabel.text = "SFX: " + entry["name"]
		$RightPanel/TypeLabel.text = "Procedural sound  -  Sfx.play(\"%s\")" % entry["name"]
		var tones: Array = Sfx.sounds[entry["name"]]
		var parts: Array = []
		for tone in tones:
			parts.append("%d Hz, %d ms" % [int(tone[0]), int(tone[1] * 1000.0)])
		var tones_text: String = ""
		for i in range(parts.size()):
			if i > 0:
				tones_text += "\n"
			tones_text += parts[i]
		$RightPanel/MetaLabel.text = ("Tones:\n" if parts.size() > 1 else "Tone:\n") + tones_text
	else:
		var m: Dictionary = entry["meta"]
		$RightPanel/NameLabel.text = m["title"]
		$RightPanel/TypeLabel.text = "Audio file track"
		var meta: String = "Used for: " + m["used"]
		meta += "\nArtist: " + m["artist"]
		if m["album"] != "":
			meta += "\nAlbum: " + m["album"]
		if m["source"] != "":
			meta += "\nSource: " + m["source"]
		$RightPanel/MetaLabel.text = meta

func _process(_delta):
	if not is_visible_in_tree() or not input_enabled:
		return
	if Input.is_action_just_pressed("ui_up"):
		_selection(-1)
	if Input.is_action_just_pressed("ui_down"):
		_selection(1)
	if Input.is_action_just_pressed("ui_accept"):
		_activate()
	if Input.is_action_just_pressed("ui_cancel"):
		Sfx.play("cancel")
		emit_signal("back")

func _selection(dir):
	selected = (selected + dir + entries.size()) % entries.size()
	_refresh_list()
	_ensure_selection_visible()
	_update_details()
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
