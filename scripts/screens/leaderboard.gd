extends CanvasLayer

# Node references.
@onready var container: VBoxContainer = $ScrollContainer/VBoxContainer
@onready var leaderboard_label: Label = $LeaderboardLabel
@onready var loading_label: Label = $LoadingLabel
@onready var error_label: Label = $ErrorLabel
@onready var retry_button: Button = $RetryButton

func _ready():
	refresh_leaderboard()
	leaderboard_label.hide()
	retry_button.hide()
	retry_button.pressed.connect(_on_retry_button_pressed)

# Refreshes the leaderboard by clearing and re-loading scores.
func refresh_leaderboard():
	loading_label.show()
	error_label.hide()
	retry_button.hide()
	clear_scores()
	
	# Load scores (automatically handles online/offline fallback).
	ScoreDatabase.load_scores(_on_scores_received)

# Clears all scores currently displayed.
func clear_scores():
	for child in container.get_children():
		child.queue_free()

# Displays the given scores in the leaderboard.
func display_scores(scores: Array):
	leaderboard_label.show()
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

# Handles the response from the score loading.
func _on_scores_received(result, response_code, headers, body):
	loading_label.hide()
	
	if response_code == 200:
		var scores = JSON.parse_string(body)
		if typeof(scores) == TYPE_ARRAY:
			display_scores(scores)
		else:
			# Handle unexpected data format
			error_label.text = "Data format error"
			error_label.show()
			retry_button.show()
	else:
		# Show error message
		error_label.text = "Error loading scores (Code %d)" % response_code
		error_label.show()
		retry_button.show()

# Handles the retry button being pressed.
func _on_retry_button_pressed():
	refresh_leaderboard()
