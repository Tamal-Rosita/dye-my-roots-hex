extends Node

export var attract_delay: float = 15.0

const INPUT_GRACE_TIME: float = 0.15

var idle_time: float = 0.0

func _ready():
	_show_view($MainMenu)

func _process(delta):
	if $AttractMode.visible:
		# Any button wakes the attract mode back to the main menu.
		if _any_input():
			_wake_from_attract()
		return
	if _current_view() == $MainMenu:
		if _any_input():
			idle_time = 0.0
		else:
			idle_time += delta
			if idle_time >= attract_delay:
				_show_attract()
	else:
		idle_time = 0.0

func _current_view():
	if $MainMenu.visible:
		return $MainMenu
	if $UserInfo.visible:
		return $UserInfo
	if $HighScoresView.visible:
		return $HighScoresView
	if $CreditsView.visible:
		return $CreditsView
	if $SoundLibrary.visible:
		return $SoundLibrary
	return null

# Exactly one view is visible at any time (plus the optional attract overlay
# on top of the menu), so no panel ever leaves the main menu active under it.
#
# Every opened view gets a short input grace: the button press that activated
# it (e.g. A on "Start Game") is still "just pressed" for the rest of that
# frame, so without the grace the name roller would instantly confirm the
# pre-filled name, any-button back screens would instantly close again, and
# the menu could re-select an option. This debounce prevents all of that.
func _show_view(node):
	$MainMenu.visible = node == $MainMenu
	$UserInfo.visible = node == $UserInfo
	$HighScoresView.visible = node == $HighScoresView
	$CreditsView.visible = node == $CreditsView
	$SoundLibrary.visible = node == $SoundLibrary
	$AttractMode.hide_attract()
	if node == $HighScoresView:
		$HighScoresView.refresh()
	elif node == $UserInfo:
		$UserInfo.open()
	_apply_input_grace(node)
	idle_time = 0.0
	print("[Landing] view: ", node.name)

func _apply_input_grace(node):
	if not node.has_method("set_input_enabled"):
		return
	node.set_input_enabled(false)
	var unlock: Timer = Timer.new()
	unlock.one_shot = true
	unlock.wait_time = INPUT_GRACE_TIME
	unlock.connect("timeout", self, "_on_grace_end", [node])
	add_child(unlock)
	unlock.start()

func _on_grace_end(node):
	if is_instance_valid(node) and node.has_method("set_input_enabled"):
		node.set_input_enabled(true)

func _show_attract():
	if _current_view() != $MainMenu:
		return
	$MainMenu.hide()
	$AttractMode.show_attract()
	idle_time = 0.0

func _wake_from_attract():
	$AttractMode.hide_attract()
	$MainMenu.show()
	_apply_input_grace($MainMenu)
	Sfx.play("select")

func _any_input() -> bool:
	return (Input.is_action_just_pressed("ui_accept")
		or Input.is_action_just_pressed("ui_cancel")
		or Input.is_action_just_pressed("ui_up")
		or Input.is_action_just_pressed("ui_down")
		or Input.is_action_just_pressed("ui_left")
		or Input.is_action_just_pressed("ui_right"))

func _on_MainMenu_option_selected(index):
	match index:
		0: # Start Game
			_show_view($UserInfo)
		1: # High Scores
			_show_view($HighScoresView)
		2: # Credits
			_show_view($CreditsView)
		3: # Sound Test (dev tool)
			_show_view($SoundLibrary)

func _on_HighScoresView_back():
	_show_view($MainMenu)

func _on_CreditsView_back():
	_show_view($MainMenu)

func _on_SoundLibrary_back():
	_show_view($MainMenu)

func _on_UserInfo_cancelled():
	_show_view($MainMenu)

func _on_UserInfo_entered(_name):
	get_tree().change_scene("res://Main.tscn")
