extends CanvasLayer

# Function that activates upon pressing the New Adventure (New Game) button.
func _on_new_adventure_button_pressed() -> void:
	GameManager.start_game()

# Function that activates upon pressing the Continue (Load Game) button.
func _on_continue_button_pressed() -> void:
	# Call the load function and wait for completion
	var success = await SaveManager.load_game()
	
	if success:
		queue_free()
	else:
		print("Load failed.")

# Function that activates upon pressing the Quit button.
func _on_quit_button_pressed() -> void:
	GameManager.quit_game()
