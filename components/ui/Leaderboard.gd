extends Panel

# Reads the persisted high-score table from SaveSystem and renders it in a
# two-column layout (rank+name on the left, amount on the right).
# Call refresh() to re-read the scores.
#
# The row of the current player (SaveSystem.get_player_name) is highlighted
# in gold, so after a session you can see where your latest score landed.

export(int) var max_entries: int = 8

const HIGHLIGHT: String = "#ffd166"
const GOLD: String = "#ffd166"
const NORMAL: String = "#cfc4ea"

func _ready():
	refresh()

func refresh():
	var scores: Array = SaveSystem.get_high_scores()
	var my_name: String = SaveSystem.get_player_name()
	var count: int = int(min(scores.size(), max_entries))
	var names: Array = []
	var amounts: Array = []
	for i in range(count):
		var entry: Dictionary = scores[i]
		var is_me: bool = my_name != "" and entry["name"] == my_name
		var color: String = HIGHLIGHT if is_me else NORMAL
		var marker: String = "> " if is_me else "  "
		names.append("[color=%s]%s%d.  %s[/color]" % [color, marker, i + 1, entry["name"]])
		amounts.append("[color=%s][right]$%.2f[/right][/color]" % [GOLD, float(entry["score"])])
	var names_text: String = ""
	var amounts_text: String = ""
	if count == 0:
		names_text = "[center]No scores yet.\nPlay a round![/center]"
	else:
		for i in range(count):
			if i > 0:
				names_text += "\n"
				amounts_text += "\n"
			names_text += names[i]
			amounts_text += amounts[i]
	$Margin/V/Rows/NamesLabel.bbcode_text = names_text
	$Margin/V/Rows/AmountsLabel.bbcode_text = amounts_text
