extends CanvasLayer

# Function that activates upon pressing the New Adventure (New Game) button.
func _on_new_adventure_button_pressed() -> void:
	GameManager.start_game()

# Function that activates upon pressing the Quit Button (Quit) button.
func _on_quit_button_pressed() -> void:
	GameManager.quit_game()
