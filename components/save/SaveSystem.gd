extends Node

# Persistent player profile + high-score table, stored as JSON under user://.
#
#   SaveSystem.get_player_name()      -> String
#   SaveSystem.set_player_name(name)  -> saves immediately
#   SaveSystem.submit_score(name, n)  -> keeps top 10 (best score per name)
#   SaveSystem.get_high_scores()      -> [{ "name": ..., "score": ... }, ...]
#
# All file access is best-effort: if user:// is not writable (e.g. a
# read-only filesystem on some cabinets) the game simply keeps everything in
# memory and never crashes.

const SAVE_PATH: String = "user://save.json"
const MAX_SCORES: int = 10

var data: Dictionary = {
	"player_name": "",
	"high_scores": []
}

func _ready():
	load_data()

func load_data():
	var file: File = File.new()
	if not file.file_exists(SAVE_PATH):
		return
	if file.open(SAVE_PATH, File.READ) != OK:
		return
	var parsed = parse_json(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	if parsed.has("player_name") and typeof(parsed["player_name"]) == TYPE_STRING:
		data["player_name"] = parsed["player_name"]
	if parsed.has("high_scores") and typeof(parsed["high_scores"]) == TYPE_ARRAY:
		data["high_scores"] = parsed["high_scores"]

func save_data():
	var file: File = File.new()
	if file.open(SAVE_PATH, File.WRITE) == OK:
		file.store_string(JSON.print(data))
		file.close()

func get_player_name() -> String:
	return data["player_name"]

func set_player_name(name: String):
	data["player_name"] = name
	save_data()

func get_high_scores() -> Array:
	return data["high_scores"]

func submit_score(name: String, score: float):
	if name == "" or score <= 0:
		return
	var scores: Array = data["high_scores"]
	var found: bool = false
	for entry in scores:
		if typeof(entry) == TYPE_DICTIONARY and entry.get("name") == name:
			if float(entry.get("score", 0.0)) < score:
				entry["score"] = score
			found = true
			break
	if not found:
		scores.append({"name": name, "score": score})
	scores.sort_custom(self, "_sort_scores")
	while scores.size() > MAX_SCORES:
		scores.pop_back()
	save_data()

func _sort_scores(a, b) -> bool:
	return float(a["score"]) > float(b["score"])
