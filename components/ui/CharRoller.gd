extends Control
class_name CharRoller

# A character roller (carousel) for arcade input, inspired by the name entry
# screens of classic arcade leaderboards.
#
# The widget shows `column_count` cells side by side. Each cell is a wheel of
# characters from `glyphs` (e.g. "0123456789ABCDEF").
#
#   LEFT / RIGHT  -> move the active column (highlighted box)
#   UP / DOWN     -> change the active column's character (wraps around)
#                     Up/down arrows are drawn around the active cell.
#   CONFIRM       -> emits confirmed(value)
#   CANCEL        -> emits cancelled()
#
# The cell size is derived from `font_size` and `widest_char`, so you resize
# the whole widget by changing a single number (font_size) and, if needed,
# the `widest_char` used to measure the column width.
#
# UP/DOWN auto-repeat while held (initial delay + interval) so scrolling
# through 16 characters feels fast on a cabinet.

signal value_changed(value)
signal confirmed(value)
signal cancelled()
signal column_changed(column)

export(String) var glyphs: String = "0123456789ABCDEF"
export(int) var column_count: int = 6
# Starting value; use characters present in glyphs (shorter values are padded
# with pad_glyph, unknown characters map to the first glyph)
export(String) var default_value: String = "FFFFFF"
export(int) var initial_column: int = 0
# Glyph size. Everything else (cells, arrows) scales off this value.
export(int) var font_size: int = 40
# Reference text used to measure the cell width; use the widest glyph in the
# set so nothing clips (e.g. "W" for letters, "F" for hex).
export(String) var widest_char: String = "0"
# Extra horizontal/vertical padding around each glyph (px).
export(Vector2) var cell_padding: Vector2 = Vector2(12, 8)
# Half-height of the up/down arrow triangles (px).
export(float) var arrow_size: float = 7.0
# Gap between the glyph and its arrows (px).
export(float) var arrow_gap: float = 4.0
# Glyph used to pad values shorter than column_count. Empty = first glyph.
export(String) var pad_glyph: String = ""
export(Color) var selected_bg: Color = Color(1, 1, 1, 0.92)
export(Color) var selected_text: Color = Color(0.25, 0.12, 0.2)
export(Color) var selected_border: Color = Color(0.886, 0.702, 0.835)
export(Color) var dim_text: Color = Color(0.9, 0.9, 0.9, 0.8)
export(float) var repeat_delay: float = 0.35
export(float) var repeat_interval: float = 0.08

var values = []                 # per-column index into glyphs
var column: int = 0             # active column
var font                        # DynamicFont
var tick_player
var hold_time: float = 0.0
var cell_size: Vector2 = Vector2(0, 0)  # computed in _recompute_layout

func _ready():
	if glyphs.length() == 0:
		glyphs = "0"
	if pad_glyph == "":
		pad_glyph = glyphs[0]
	_setup_font()
	_setup_tick_player()
	_recompute_layout()
	reset()

func _setup_font():
	var font_data = load("res://fonts/rainyhearts.ttf")
	font = DynamicFont.new()
	if font_data:
		font.font_data = font_data
	font.size = font_size

func _setup_tick_player():
	var generator: AudioStreamGenerator = AudioStreamGenerator.new()
	generator.mix_rate = 22050
	generator.buffer_length = 0.2
	tick_player = AudioStreamPlayer.new()
	tick_player.stream = generator
	add_child(tick_player)

func _recompute_layout():
	var measure: Vector2 = font.get_string_size(widest_char)
	var arrow_area: float = arrow_size + arrow_gap
	var cell_w: float = measure.x + cell_padding.x * 2
	var cell_h: float = font.get_height() + arrow_area * 2 + cell_padding.y * 2
	cell_size = Vector2(cell_w, cell_h)
	rect_size = Vector2(cell_w * column_count, cell_h)

func reset():
	column = initial_column
	set_value(default_value)

func get_value() -> String:
	var result: String = ""
	for index in values:
		result += glyphs[index]
	return result

func set_value(text):
	values = []
	for i in range(column_count):
		var ch: String = pad_glyph
		if i < text.length():
			ch = text[i]
		values.append(_glyph_index(ch))
	update()
	emit_signal("value_changed", get_value())

func get_column() -> int:
	return column

func set_column(index):
	column = clamp(index, 0, column_count - 1)
	update()
	emit_signal("column_changed", column)

func _glyph_index(ch) -> int:
	var index: int = glyphs.find(ch)
	if index == -1:
		return 0
	return index

func _move_column(dir):
	set_column(column + dir)
	_play_tick(990.0)

func _step(dir):
	values[column] = (values[column] + dir + glyphs.length()) % glyphs.length()
	update()
	_play_tick(1320.0)
	emit_signal("value_changed", get_value())

func _process(delta):
	if not is_visible_in_tree():
		return
	if Input.is_action_just_pressed("ui_left"):
		_move_column(-1)
	if Input.is_action_just_pressed("ui_right"):
		_move_column(1)
	var dir: int = 0
	if Input.is_action_pressed("ui_up"):
		dir = 1
	elif Input.is_action_pressed("ui_down"):
		dir = -1
	if dir != 0:
		if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down"):
			hold_time = 0.0
			_step(dir)
		else:
			hold_time += delta
			if hold_time >= repeat_delay:
				_step(dir)
				hold_time = repeat_delay - repeat_interval
	else:
		hold_time = 0.0
	if Input.is_action_just_pressed("ui_accept"):
		emit_signal("confirmed", get_value())
	if Input.is_action_just_pressed("ui_cancel"):
		emit_signal("cancelled")

func _draw():
	if not font:
		return
	for c in range(column_count):
		var is_active: bool = c == column
		var cell_rect: Rect2 = Rect2(c * cell_size.x, 0, cell_size.x, cell_size.y)
		var cx: float = cell_rect.position.x + cell_size.x * 0.5
		if is_active:
			draw_rect(cell_rect, selected_bg, true)
			draw_rect(cell_rect, selected_border, false, 1.5)
			_draw_arrows(cx, cell_size.y)
			_draw_glyph(font, glyphs[values[c]], Vector2(cx, cell_size.y * 0.9), selected_text)
		else:
			_draw_glyph(font, glyphs[values[c]], Vector2(cx, cell_size.y * 0.9), dim_text)

# Up/down arrows around the active cell's glyph, drawn in the same color as
# the glyph so they stay readable on top of the highlighted cell background.
func _draw_arrows(cx: float, cell_h: float):
	var top_y: float = arrow_size + arrow_gap
	var bottom_y: float = cell_h - arrow_size - arrow_gap
	var up: PoolVector2Array = PoolVector2Array([
		Vector2(cx, top_y - arrow_size),
		Vector2(cx - arrow_size, top_y + arrow_size),
		Vector2(cx + arrow_size, top_y + arrow_size)
	])
	draw_colored_polygon(up, selected_text)
	var down: PoolVector2Array = PoolVector2Array([
		Vector2(cx, bottom_y + arrow_size),
		Vector2(cx - arrow_size, bottom_y - arrow_size),
		Vector2(cx + arrow_size, bottom_y - arrow_size)
	])
	draw_colored_polygon(down, selected_text)

func _draw_glyph(fnt, text: String, center: Vector2, color: Color):
	var size: Vector2 = fnt.get_string_size(text)
	var pos: Vector2 = center - Vector2(size.x * 0.5, fnt.get_height() * 0.5)
	draw_string(fnt, pos, text, color)

# Tiny synthesized arcade "tick" so scrolling the wheels feels responsive
# without needing new audio assets.
func _play_tick(freq):
	if not tick_player:
		return
	var playback = tick_player.get_stream_playback()
	if not playback or not playback.has_method("push_frame"):
		return
	if playback.has_method("clear_buffer"):
		playback.clear_buffer()
	var mix_rate: int = 22050
	var frame_count: int = int(mix_rate * 0.05)
	for i in range(frame_count):
		var t: float = float(i) / mix_rate
		var v: float = -0.2
		if int(t * freq * 2) % 2 == 0:
			v = 0.2
		var envelope: float = 1.0 - float(i) / frame_count
		playback.push_frame(Vector2(v * envelope, v * envelope))
