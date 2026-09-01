extends Panel

# Reads the persisted high-score table from SaveSystem and renders it.
# Call refresh() to re-read the scores.

export(int) var max_entries: int = 8

func _ready():
	refresh()

func refresh():
	var scores: Array = SaveSystem.get_high_scores()
	var lines: Array = []
	lines.append("[center][color=#e2b3d5]HIGH SCORES[/color][/center]")
	if scores.empty():
		lines.append("[center]No scores yet.[/center]")
	else:
		var count: int = int(min(scores.size(), max_entries))
		for i in range(count):
			var entry: Dictionary = scores[i]
			lines.append("%d.  %s  $%.2f" % [i + 1, entry["name"], float(entry["score"])])
	var text: String = ""
	for i in range(lines.size()):
		if i > 0:
			text += "\n"
		text += lines[i]
	$ScoresLabel.bbcode_text = text
