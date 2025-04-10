extends Node

# Screen variables.
var main_menu = preload("res://scenes/screens/main_menu.tscn")
var pause_menu = preload("res://scenes/screens/pause_menu.tscn")
var game_over = preload("res://scenes/screens/game_over.tscn")
var cutscene = preload("res://scenes/ui/cutscenes/cutscene.tscn")
var module_pickup_cutscene = preload("res://scenes/ui/cutscenes/module_pickup_cutscene.tscn")

# Area variables.
var start_point = preload("res://scenes/areas/forgotten_isles/start_point.tscn")

# Sets the processing mode to always
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

# Starts the game.
func start_game() -> void:
	transition_to_scene(start_point.resource_path)
	GameState.reset_score()

# Checks for pausing.
func _input(event):
	if event.is_action_pressed("pause"):
		if not can_pause():
			return
		pause_game()

# Combined pause condition checker.
func can_pause() -> bool:
	# Check if any unpausable nodes exist.
	if get_tree().get_nodes_in_group("unpausable").size() > 0:
		return false
	
	# Check player invulnerability.
	var player = get_tree().get_first_node_in_group("player")
	if player and player.is_invulnerable:
		return false
	
	return true

# Pauses the game.
func pause_game() -> void:
	# Checks if the game is paused.
	if get_tree().paused:
		get_tree().paused = false

		MusicManager.undim_music()

		# Checks if the pause menu already exists.
		var existing_pause_menu = get_tree().root.get_node_or_null("PauseMenu")
		# Frees the pause menu if it exists.
		if existing_pause_menu:
			existing_pause_menu.queue_free()
	else:
		get_tree().paused = true

		MusicManager.dim_music()

		# Instantiates the pause menu.
		var pause_menu_instance = pause_menu.instantiate()
		get_tree().root.add_child(pause_menu_instance)

# Displays game over screen.
func to_game_over() -> void:
	transition_to_scene(game_over.resource_path)

# Quits the game.
func quit_game() -> void:
	get_tree().quit()

# For scene transitions.
func transition_to_scene(scene_path) -> void:
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file(scene_path)
