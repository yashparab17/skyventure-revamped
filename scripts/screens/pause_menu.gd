extends CanvasLayer

# Screen variables.
var main_menu = preload("res://scenes/screens/main_menu.tscn")

func _on_resume_button_pressed() -> void:
	MusicManager.undim_music()
	get_tree().paused = false
	queue_free()

func _on_main_menu_button_pressed() -> void:
	MusicManager.undim_music()
	GameManager.transition_to_scene(main_menu.resource_path)
	get_tree().paused = false
	queue_free()
