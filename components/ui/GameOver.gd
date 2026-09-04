extends Control

# Game-over overlay, drawn on top of everything else in the Main scene.
# Shown when the session (turn) timer expires; press A to return to the title
# screen (the leaderboard there reflects the session that just ended).

const GOLD: String = "#ffd166"

func _on_OneInfiniteMechanic_turn_ended(gains):
	visible = true
	$FinalGains.bbcode_text = "[center][color=#f2e5f0]YOU EARNED[/color]\n[color=%s]$%.2f[/color][/center]" % [GOLD, gains]
	Sfx.play("turn_over")

func _process(_delta):
	if visible and Input.is_action_just_pressed("ui_accept"):
		Sfx.play("confirm")
		get_tree().change_scene("res://components/ui/Landing.tscn")
