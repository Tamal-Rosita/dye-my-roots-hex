extends Control

signal entered(name)
signal cancelled

func _ready():
	_prefill_name()

# Forward the landing screen's input debounce to the name roller, so the
# press that opened this panel cannot instantly confirm the pre-filled name.
func set_input_enabled(value: bool):
	$NameRoller.set_input_enabled(value)

# Called by the landing screen whenever the name panel becomes the active
# view, so the roller always shows the latest persisted name.
func open():
	_prefill_name()

# Start the roller on the persisted name (or the default if none saved).
func _prefill_name():
	var saved: String = SaveSystem.get_player_name()
	if saved == "":
		$NameRoller.reset()
	else:
		$NameRoller.set_value(saved)

func _on_NameRoller_confirmed(name):
	var clean_name: String = name.strip_edges()
	if clean_name == "":
		clean_name = "PLAYER"
	SaveSystem.set_player_name(clean_name)
	emit_signal("entered", clean_name)

func _on_NameRoller_cancelled():
	emit_signal("cancelled")
