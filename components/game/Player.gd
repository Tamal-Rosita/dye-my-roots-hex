extends Node2D

signal submit(color)

func _ready():
	$Cloud.visible = false

func reset():
	$Cloud.visible = true
	$Cloud/HexRoller.reset()

func preview(color):
	$Cloud/Preview.self_modulate = color

func _on_HexRoller_value_changed(hex_value):
	var validation = validate_color(hex_value)
	if validation.is_valid:
		preview(validation.color)

func _on_HexRoller_confirmed(hex_value):
	var validation = validate_color(hex_value)
	if validation.is_valid:
		emit_signal("submit", validation.color)
	else:
		$InvalidStreamPlayer.play()

func validate_color(new_text):
	var color: Color = Color(new_text)
	var is_valid_color: bool = not color.is_equal_approx(Color.black)
	var has_valid_length: bool = len(new_text) == 6
	return {
		"is_valid": is_valid_color and has_valid_length, 
		"color": color
	}
