extends Node

signal completed(gains)
signal turn_ended(gains)
signal turn_time_changed(remaining)
signal reaction(likeness)

export var base_price: int = 5
export var lose_price: int = 15
export var min_likeness: int = 72
export var price_multiplier: float = 0.5
# Session ("turn") clock: the number of seconds the whole play session lasts.
# When it hits zero the turn ends and the final earnings are shown.
export var turn_time: float = 60.0
# Seconds added to the turn clock when a round is won.
export var win_time_bonus: float = 5.0
# Extra seconds per likeness point above min_likeness (up to ~5.6s at 100%).
export var likeness_bonus_per_point: float = 0.2
# Extra seconds for answering fast, scaled by the color timer still remaining
# when the guess was submitted (up to this value for instant guesses).
export var speed_bonus_max: float = 8.0
# Beep once per second during the last seconds of the session clock.
export var turn_warning_seconds: float = 5.0

var gains: float = 0
var turn_timer: Timer = Timer.new()  # session countdown
var turn_over: bool = false
var last_warning_second: int = -1
# After a guess the round is closed: the result and Ms Kelly's reaction are
# shown and the roller is locked until the player presses A ("next customer").
var awaiting_next: bool = false

func _ready():
	turn_timer.connect("timeout", self, "_on_turn_timeout")
	turn_timer.one_shot = true
	add_child(turn_timer)

# Begins a new session: zeroes earnings, starts the turn clock and the first
# round. Called when the intro dialogue ends.
func start_turn():
	gains = 0
	turn_over = false
	awaiting_next = false
	turn_timer.wait_time = turn_time
	turn_timer.start()
	reset()
	$Player.set_input_enabled(true)

func reset():
	$Dye.reset()
	$Player.reset()
		
func failed():
	gains -= stepify(lose_price, 0.01)
	Sfx.play("fail")
	print("Failed!")
	
func won(likeness):
	var price = base_price + price_multiplier * likeness
	gains += stepify(price, 0.01)
	$WinSFXPlayer.play_all()
	print("Dollars earned: %.02f" % price)

func _process(delta):
	if turn_over or turn_timer.is_stopped():
		last_warning_second = -1
		return
	var remaining: float = turn_timer.time_left
	emit_signal("turn_time_changed", remaining)
	# Audible warning in the last seconds of the session clock.
	if remaining <= turn_warning_seconds and remaining > 0.0:
		var sec: int = int(ceil(remaining))
		if sec != last_warning_second:
			last_warning_second = sec
			Sfx.play("turn_warning")
	else:
		last_warning_second = -1
	# After a guess, wait for an explicit A press before the next round starts,
	# so the player can read the result and Ms Kelly's reaction safely.
	if awaiting_next and Input.is_action_just_pressed("ui_accept"):
		_advance_after_guess()

func _on_turn_timeout():
	end_turn()

# Leaves the current session (hold-cancel in the HUD) and returns to the
# title screen. Earnings are recorded first.
func quit_to_title():
	if not turn_over:
		SaveSystem.submit_score(SaveSystem.get_player_name(), gains)
	$Dye.stop()
	get_tree().change_scene("res://components/ui/Landing.tscn")

func end_turn():
	if turn_over:
		return
	turn_over = true
	$Dye.stop()
	$Player.set_input_enabled(false)
	SaveSystem.submit_score(SaveSystem.get_player_name(), gains)
	emit_signal("turn_ended", gains)

# Color timer expired: auto-submit whatever the player has on the roller.
func _on_Dye_timeout():
	if turn_over:
		return
	$Player.auto_submit()

func _on_Dye_completed(likeness):
	if turn_over:
		return
	if likeness < min_likeness:
		failed()
	else:
		won(likeness)
		_grant_time_bonus(likeness)
	SaveSystem.submit_score(SaveSystem.get_player_name(), gains)
	emit_signal("reaction", likeness)
	emit_signal("completed", gains)
	_await_next()

func _on_Player_submit(color):
	$Dye.submit(color)

# Closes the round: locks the roller (so a stray A cannot submit a color while
# the result/reaction is on screen) and asks for an explicit "next" press.
func _await_next():
	awaiting_next = true
	$Player.set_input_enabled(false)
	$Player.show_next_prompt()

func _advance_after_guess():
	awaiting_next = false
	$Player.hide_next_prompt()
	reset()
	# Re-enable the roller only on the next frame, so the A press that
	# confirmed "next customer" cannot also submit the fresh white guess.
	$Player.call_deferred("set_input_enabled", true)

# Good and/or fast guesses add time to the turn clock.
func _grant_time_bonus(likeness):
	if turn_over or turn_timer.is_stopped():
		return
	var ratio: float = clamp($Dye.timer.time_left / $Dye.wait_time, 0.0, 1.0)
	var bonus: float = win_time_bonus
	bonus += (likeness - min_likeness) * likeness_bonus_per_point
	bonus += ratio * speed_bonus_max
	# Capture the remaining time BEFORE stopping: Timer.stop() resets time_left.
	var remaining: float = turn_timer.time_left
	turn_timer.stop()
	turn_timer.wait_time = remaining + bonus
	turn_timer.start()
	Sfx.play("bonus")
	print("Turn time bonus: +%.1fs" % bonus)
