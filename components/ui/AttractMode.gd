extends Control

# Attract mode ("screen saver"): shown on the title screen after some idle
# time, displaying the high scores. Any input dismisses it (Landing handles
# the dismissal).

func show_attract():
	refresh()
	visible = true

func hide_attract():
	visible = false

func refresh():
	$Leaderboard.refresh()
