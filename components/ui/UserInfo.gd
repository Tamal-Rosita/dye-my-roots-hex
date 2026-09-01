extends Control

signal entered(name)

func _ready():
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
