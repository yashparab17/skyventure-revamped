extends Node

# Supabase parameters.
const SUPABASE_URL = "https://gwooxujnvyfkfhbtaiym.supabase.co"
const API_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd3b294dWpudnlma2ZoYnRhaXltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM1ODE3NzQsImV4cCI6MjA1OTE1Nzc3NH0.ksMt2el702UKV28d8OCtKfCZbU9HcQiKBSPi4DPjUH4"
const ENDPOINT = "/rest/v1/scores"

# HTTP request node.
var http_request: HTTPRequest

func _ready():
	# Create a new HTTP request node.
	http_request = HTTPRequest.new()
	add_child(http_request)

# Saves a score to the scores table.
func save_score(player_name: String, score: int):
	# Supabase API key headers.
	var headers = [
		"apikey: " + API_KEY,
		"Authorization: Bearer " + API_KEY,
		"Content-Type: application/json",
		"Prefer: return=minimal"
	]
	
	# Score data in JSON format.
	var body = JSON.stringify({
		"name": player_name,
		"score": score
	})
	
	# URL for the scores table.
	var url = SUPABASE_URL + ENDPOINT
	http_request.request(url, headers, HTTPClient.METHOD_POST, body)

# Retrieves top scores from the scores table.
func get_top_scores(limit: int = 10):
	# Supabase API key headers.
	var headers = [
		"apikey: " + API_KEY,
		"Authorization: Bearer " + API_KEY,
		"Accept: application/json"
	]
	
	# URL for the scores table with query parameters.
	var url = SUPABASE_URL + ENDPOINT + "?select=name,score&order=score.desc&limit=" + str(limit)
	http_request.request(url, headers, HTTPClient.METHOD_GET)
