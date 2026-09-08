extends Control

signal back

# Full-screen credits view reachable from the main menu.
# ANY button goes back to the menu (input is debounced on open, so the same
# press that opened this view cannot close it again in the same frame).

var input_enabled: bool = true

func set_input_enabled(value: bool):
	input_enabled = value

func _ready():
	# Append the running version (from Project Settings) to the credits text.
	var version: String = str(ProjectSettings.get_setting("application/config/version"))
	if version == "" or version == "null":
		version = "dev"
	$CreditsText.bbcode_text += "\n\n[center][color=#e2b3d5]v" + version + "[/color][/center]"

func _process(_delta):
	if not is_visible_in_tree() or not input_enabled:
		return
	if _any_input():
		Sfx.play("cancel")
		emit_signal("back")

func _any_input() -> bool:
	return (Input.is_action_just_pressed("ui_accept")
		or Input.is_action_just_pressed("ui_cancel")
		or Input.is_action_just_pressed("ui_up")
		or Input.is_action_just_pressed("ui_down")
		or Input.is_action_just_pressed("ui_left")
		or Input.is_action_just_pressed("ui_right"))
