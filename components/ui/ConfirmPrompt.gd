extends Control

signal confirmed
signal cancelled

# Generic confirmation prompt: shows a message and waits for A (yes) or
# B (no). Any other button acts as "no".

export(String) var prompt_text: String = "Are you sure?"

var input_enabled: bool = true

func set_input_enabled(value: bool):
	input_enabled = value

func _ready():
	$Panel/MessageLabel.bbcode_text = "[center][color=#f6e7f5]%s[/color][/center]" % prompt_text

func open():
	visible = true

func close():
	visible = false

func _process(_delta):
	if not is_visible_in_tree() or not input_enabled:
		return
	if Input.is_action_just_pressed("ui_accept"):
		Sfx.play("confirm")
		emit_signal("confirmed")
	elif Input.is_action_just_pressed("ui_cancel"):
		Sfx.play("cancel")
		emit_signal("cancelled")
