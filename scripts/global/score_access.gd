extends Node

const SAVE_PATH = "res://scores.json"

static func save_score(name: String, score: int):
	var scores = load_scores()
	scores.append({"name": name, "score": score})
	
	# Sort by score (highest first).
	scores.sort_custom(func(a, b): return a["score"] > b["score"])
	
	# Keep only top scores (e.g., top 10).
	if scores.size() > 10:
		scores.resize(10)
	
	# Save to file.
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(scores))

static func load_scores():
	if not FileAccess.file_exists(SAVE_PATH):
		return []
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	return JSON.parse_string(content)
