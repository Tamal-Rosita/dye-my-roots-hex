extends Control

# Game-over overlay, drawn on top of everything else in the Main scene.
# Shown when the session (turn) timer expires; press A to return to the title
# screen (the leaderboard there reflects the session that just ended).

func _on_OneInfiniteMechanic_turn_ended(gains):
	visible = true
	$FinalGains.text = "You earned $%.2f" % gains

func _process(_delta):
	if visible and Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene("res://components/ui/Landing.tscn")
