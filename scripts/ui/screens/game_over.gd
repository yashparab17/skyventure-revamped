extends CanvasLayer

@onready var score_label: Label = $ScoreLabel
@onready var name_input: LineEdit = $NameInput
@onready var submit_button: Button = $SubmitButton
@onready var status_label: Label = $StatusLabel

var leaderboard = preload("res://scenes/ui/screens/leaderboard.tscn")
var final_score = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	final_score = ScoreManager.score
	score_label.text = "Final Score: " + str(final_score)
	status_label.hide()

# Called when the submit button is pressed.
func _on_submit_button_pressed() -> void:
	# Get the user's name from the input field.
	var player_name = name_input.text.strip_edges()
	
	# If the user didn't enter a name, use "Anonymous" instead.
	if player_name == "":
		player_name = "Anonymous"
	
	# Disable the input field and submit button while the score is being submitted.
	name_input.editable = false
	status_label.text = "Submitting score..."
	status_label.show()
	
	# Save the score to the scoreboard (both locally and online).
	ScoreAccess.save_score(player_name, final_score)
	
	# Wait for 1.5 seconds to ensure the score is fully submitted.
	await get_tree().create_timer(1.5).timeout
	
	# Transition to the leaderboard screen.
	GameManager.transition_to_scene(leaderboard.resource_path)

func _on_quit_button_pressed() -> void:
	# Quit the game.
	GameManager.quit_game()
