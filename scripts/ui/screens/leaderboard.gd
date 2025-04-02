extends CanvasLayer

# Node references.
@onready var container: VBoxContainer = $ScrollContainer/VBoxContainer
@onready var loading_label: Label = $LoadingLabel
@onready var error_label: Label = $ErrorLabel
@onready var retry_button: Button = $RetryButton

func _ready():
	refresh_leaderboard()
	retry_button.hide()

# Refreshes the leaderboard by clearing and re-loading scores.
func refresh_leaderboard():
	loading_label.show()
	error_label.hide()
	retry_button.hide()
	clear_scores()
	
	# Try to load online scores first, with local fallback.
	ScoreAccess.get_online_scores(_on_scores_received)

# Clears all scores currently displayed.
func clear_scores():
	for child in container.get_children():
		child.queue_free()

# Displays the given scores in the leaderboard.
func display_scores(scores: Array):
	clear_scores()
	
	if scores.is_empty():
		var label = Label.new()
		label.text = "No scores yet! Be the first!"
		container.add_child(label)
		return
	
	# Create a new label for each score and add it to the container.
	for i in range(scores.size()):
		var entry = scores[i]
		var label = Label.new()
		label.text = "%d. %s - %d" % [i + 1, entry["name"], entry["score"]]
		container.add_child(label)

# Handles the response from the online scores API.
func _on_scores_received(result, response_code, headers, body):
	loading_label.hide()
	
	# If the request was successful, try to parse the JSON response.
	if response_code == 200:
		var scores = JSON.parse_string(body.get_string_from_utf8())
		if typeof(scores) == TYPE_ARRAY:
			display_scores(scores)
		else:
			# Fallback to local scores if online format is unexpected
			error_label.text = "Using local scores"
			error_label.show()
			display_scores(ScoreAccess.load_scores())
	else:
		# If there was an error, display the error message.
		error_label.text = "Connection failed (Error %d)" % response_code
		error_label.show()
		retry_button.show()
		# Fallback to local scores.
		display_scores(ScoreAccess.load_scores())

# Handles the retry button being pressed.
func _on_retry_button_pressed():
	refresh_leaderboard()
