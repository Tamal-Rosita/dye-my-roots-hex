extends Node2D

signal submit(color)

func _ready():
	$Cloud.visible = false
	$Cloud/NextPrompt.visible = false

func reset():
	$Cloud.visible = true
	$Cloud/HexRoller.reset()
	$Cloud/NextPrompt.visible = false

# The mechanic locks the roller while the guess result + reaction are shown,
# so stray button presses cannot submit a color (e.g. an accidental white).
func set_input_enabled(value: bool):
	$Cloud/HexRoller.set_input_enabled(value)

func show_next_prompt():
	$Cloud/NextPrompt.visible = true

func hide_next_prompt():
	$Cloud/NextPrompt.visible = false

func preview(color):
	$Cloud/Preview.self_modulate = color

# Called when the color timer expires: submits whatever value is on the roller
# so the round is always scored, even when the player runs out of time.
func auto_submit():
	var validation = validate_color($Cloud/HexRoller.get_value())
	if validation.is_valid:
		emit_signal("submit", validation.color)

func _on_HexRoller_value_changed(hex_value):
	var validation = validate_color(hex_value)
	if validation.is_valid:
		preview(validation.color)

func _on_HexRoller_confirmed(hex_value):
	var validation = validate_color(hex_value)
	if validation.is_valid:
		emit_signal("submit", validation.color)
	else:
		Sfx.play("denied")

# Character-based hex validation. Black ("000000") is a perfectly valid color:
# unlike the old Color()-sentinel approach, validation never depends on the
# parsed value, so black is treated exactly like any other guess.
func is_valid_hex_number(text: String) -> bool:
	if len(text) != 6:
		return false
	for i in range(6):
		var ch: String = text[i]
		var is_digit: bool = ch >= "0" and ch <= "9"
		var is_upper: bool = ch >= "A" and ch <= "F"
		var is_lower: bool = ch >= "a" and ch <= "f"
		if not (is_digit or is_upper or is_lower):
			return false
	return true

func validate_color(new_text):
	return {
		"is_valid": is_valid_hex_number(new_text),
		"color": Color(new_text)
	}
