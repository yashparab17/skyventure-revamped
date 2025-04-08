extends Node

# Supabase parameters.
const SUPABASE_URL = "https://gwooxujnvyfkfhbtaiym.supabase.co"
const API_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd3b294dWpudnlma2ZoYnRhaXltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM1ODE3NzQsImV4cCI6MjA1OTE1Nzc3NH0.ksMt2el702UKV28d8OCtKfCZbU9HcQiKBSPi4DPjUH4"
const ENDPOINT = "/rest/v1/scores"

# Local storage.
const SAVE_PATH = "user://scores.json"
var use_online = true

# HTTP request node.
var http_request: HTTPRequest

func _ready():
	# Create a new HTTP request node.
	http_request = HTTPRequest.new()
	add_child(http_request)

# Saves a score both locally and online (if enabled).
func save_score(player_name: String, score: int):
	# Always save locally as fallback.
	_save_score_local(player_name, score)
	
	# Save online if enabled.
	if use_online:
		_save_score_online(player_name, score)

# Loads scores - tries online first if enabled, falls back to local.
func load_scores(callback: Callable = Callable()):
	if use_online:
		http_request.request_completed.connect(_on_scores_loaded.bind(callback), CONNECT_ONE_SHOT)
		_get_online_scores()
	else:
		var scores = _load_local_scores()
		if callback.is_valid():
			callback.call(200, 200, [], JSON.stringify(scores))

# Saves score online.
func _save_score_online(player_name: String, score: int):
	var headers = [
		"apikey: " + API_KEY,
		"Authorization: Bearer " + API_KEY,
		"Content-Type: application/json",
		"Prefer: return=minimal"
	]
	
	var body = JSON.stringify({
		"name": player_name,
		"score": score
	})
	
	var url = SUPABASE_URL + ENDPOINT
	http_request.request(url, headers, HTTPClient.METHOD_POST, body)

# Retrieves score.
func _get_online_scores(limit: int = 10):
	var headers = [
		"apikey: " + API_KEY,
		"Authorization: Bearer " + API_KEY,
		"Accept: application/json"
	]
	
	var url = SUPABASE_URL + ENDPOINT + "?select=name,score&order=score.desc&limit=" + str(limit)
	http_request.request(url, headers, HTTPClient.METHOD_GET)

# Saves score locally.
func _save_score_local(player_name: String, score: int):
	var local_scores = _load_local_scores()
	local_scores.append({"name": player_name, "score": score})
	local_scores.sort_custom(func(a, b): return a["score"] > b["score"])
	if local_scores.size() > 10:
		local_scores.resize(10)
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(local_scores))

# Retrieves score locally.
func _load_local_scores():
	if not FileAccess.file_exists(SAVE_PATH):
		return []
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	return JSON.parse_string(content)

# Handles online scores being loaded.
func _on_scores_loaded(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, callback: Callable):
	if response_code != 200:
		# If online fails, return local scores.
		var scores = _load_local_scores()
		callback.call(response_code, response_code, headers, JSON.stringify(scores))
	else:
		callback.call(result, response_code, headers, body.get_string_from_utf8())
