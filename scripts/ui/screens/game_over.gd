extends CanvasLayer

# Preloading main menu.
var main_menu = preload("res://scenes/ui/screens/main_menu.tscn")

# Function to go back to the main menu.
func _on_main_menu_button_pressed() -> void:
	GameManager.transition_to_scene(main_menu.resource_path)

# Function that activates upon pressing the Quit Button (Quit) button.
func _on_quit_button_pressed() -> void:
	GameManager.quit_game()
