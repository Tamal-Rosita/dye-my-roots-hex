extends Control

signal exit_requested

# Hold CANCEL to leave the running game back to the title screen. The ring
# (ExitHold) fills while the button is held; releasing resets it.

export var exit_hold_time: float = 1.2

var can_exit: bool = false
var exit_hold: float = 0.0
var exit_fired: bool = false

func _ready():
	$Panel/Gains.text = "$0"
	$Panel/Time.text = "TIME --"
	$ExitHold.set_label("HOLD\nTO EXIT")

# The main scene enables this once the intro dialogue has ended, so holding
# cancel during the dialogue only skips it instead of quitting the game.
func set_can_exit(value: bool):
	can_exit = value
	if not value:
		_reset_exit_hold()
		exit_fired = false

func set_money(amount):
	$Panel/Gains.text = "$%s" % amount

func set_time(remaining):
	$Panel/Time.text = "TIME %d" % int(ceil(remaining))

func _on_OneInfiniteMechanic_completed(gains):
	set_money(gains)

func _on_OneInfiniteMechanic_turn_time_changed(remaining):
	set_time(remaining)

func _process(delta):
	if not can_exit:
		return
	if _game_over_visible():
		_reset_exit_hold()
		return
	if Input.is_action_pressed("ui_cancel"):
		if exit_fired:
			return
		exit_hold += delta
		$ExitHold.visible = true
		$ExitHold.set_progress(exit_hold / exit_hold_time)
		if exit_hold >= exit_hold_time:
			_complete_exit()
	else:
		if exit_fired or exit_hold > 0.0:
			exit_fired = false
			_reset_exit_hold()

func _game_over_visible() -> bool:
	var overlay = get_node_or_null("../GameOver")
	return overlay != null and overlay.visible

func _reset_exit_hold():
	if exit_hold > 0.0:
		exit_hold = 0.0
	$ExitHold.visible = false
	$ExitHold.set_progress(0.0)

func _complete_exit():
	exit_fired = true
	_reset_exit_hold()
	Sfx.play("cancel")
	emit_signal("exit_requested")
