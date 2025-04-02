extends Node

const SAVE_PATH = "user://scores.json"
var use_online = true

# Saves a score locally and online aswell.
func save_score(name: String, score: int):
	# Always save locally as fallback.
	var local_scores = load_scores()
	local_scores.append({"name": name, "score": score})
	local_scores.sort_custom(func(a, b): return a["score"] > b["score"])
	if local_scores.size() > 10:
		local_scores.resize(10)
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(local_scores))
	
	# Save online if enabled.
	if use_online:
		SupabaseLeaderboard.save_score(name, score)

# Loads the scores.
func load_scores():
	if not FileAccess.file_exists(SAVE_PATH):
		return []
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	return JSON.parse_string(content)

# Gets the online scores from the Supabase database.
func get_online_scores(callback: Callable):
	if use_online:
		SupabaseLeaderboard.http_request.connect("request_completed", callback, CONNECT_ONE_SHOT)
		SupabaseLeaderboard.get_top_scores()
	else:
		callback.call(200, 200, [], JSON.stringify(load_scores()))
