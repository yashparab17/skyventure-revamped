extends CanvasLayer

# Screen variables.
const MAIN_MENU_PATH = "res://scenes/screens/main_menu.tscn"

# Resumes the game.
func _on_resume_button_pressed() -> void:
	MusicManager.undim_music()
	get_tree().paused = false
	queue_free()

# Loads the main menu.
func _on_main_menu_button_pressed() -> void:
	MusicManager.undim_music()
	GameManager.transition_to_scene(MAIN_MENU_PATH)
	get_tree().paused = false
	queue_free()
