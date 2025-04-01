extends CanvasLayer

# Node references.
@onready var score_label: Label = $ScoreLabel
@onready var name_input: LineEdit = $NameInput

# Preloading leaderboard.
var leaderboard = preload("res://scenes/ui/screens/leaderboard.tscn")

# Final score variable.
var final_score = 0

func _ready() -> void:
	final_score = ScoreManager.score
	score_label.text = "Final Score: " + str(final_score)
	
# Function to submit the name, score, and also redirect to the main menu.
func _on_submit_button_pressed() -> void:
	# Retrieves the player name from the input.
	var player_name = name_input.text.strip_edges()
	
	# If no player name is provided, then use the name "Anonymous."
	if player_name == "":
		player_name = "Anonymous"
	
	# Save to leaderboard.
	ScoreAccess.save_score(player_name, final_score)
	
	GameManager.transition_to_scene(leaderboard.resource_path)

# Function that activates upon pressing the Quit Button (Quit) button.
func _on_quit_button_pressed() -> void:
	GameManager.quit_game()
