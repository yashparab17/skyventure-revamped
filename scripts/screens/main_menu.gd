extends CanvasLayer

@onready var continue_button: Button = $Control/PanelContainer/MarginContainer/VBoxContainer/ContinueButton

func _ready() -> void:
	var main_menu_music = preload("res://assets/music/ao_no_sumika.mp3")
	MusicManager.play_music(main_menu_music)

	if not SaveManager.save_file_exists():
		continue_button.hide()

# Function that activates upon pressing the New Adventure (New Game) button.
func _on_new_adventure_button_pressed() -> void:
	MusicManager.stop_music()
	GameManager.start_game()

# Function that activates upon pressing the Continue (Load Game) button.
func _on_continue_button_pressed() -> void:
	# Call the load function and wait for completion
	MusicManager.stop_music()
	await get_tree().create_timer(0.5).timeout
	var success = await SaveManager.load_game()
	
	if success:
		queue_free()
	else:
		print("Load failed.")

# Function that activates upon pressing the Quit button.
func _on_quit_button_pressed() -> void:
	GameManager.quit_game()
