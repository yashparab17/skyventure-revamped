extends CanvasLayer

# Node references.
@onready var score_label: Label = $ScoreLabel
@onready var name_input: LineEdit = $NameInput
@onready var submit_button: Button = $PanelContainer/MarginContainer/VBoxContainer/SubmitButton
@onready var status_label: Label = $StatusLabel

# Preloading screens.
@onready var leaderboard = preload("res://scenes/screens/leaderboard.tscn")
@onready var main_menu = preload("res://scenes/screens/main_menu.tscn")

# Final score to be submitted.
var final_score: int = 0

# Preloading music.
@onready var music = preload("res://assets/music/game_over.mp3")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not MusicManager.is_playing() or not MusicManager.is_current_music(music):
		MusicManager.play_music(music)
	final_score = GameState.score
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
	
	# Save the score to the scoreboard (either locally and online).
	ScoreDatabase.save_score(player_name, final_score)
	
	# Wait for 1.5 seconds to ensure the score is fully submitted.
	await get_tree().create_timer(1.5).timeout
	
	# Transition to the leaderboard screen.
	GameManager.transition_to_scene(leaderboard.resource_path, true)

func _on_main_menu_button_pressed() -> void:
	GameManager.transition_to_scene(main_menu.resource_path, true)
