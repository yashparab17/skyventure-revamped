extends Node

# Screen variables.
var main_menu = preload("res://scenes/screens/main_menu.tscn")
var pause_menu = preload("res://scenes/screens/pause_menu.tscn")
var game_over = preload("res://scenes/screens/game_over.tscn")

# UI variables.
var cutscene = preload("res://scenes/ui/cutscenes/cutscene.tscn")
var module_pickup_cutscene = preload("res://scenes/ui/cutscenes/module_pickup_cutscene.tscn")

# Transition variables.
var simple_transition = preload("res://scenes/screens/simple_transition.tscn")
var fancy_transition = preload("res://scenes/screens/fancy_transition.tscn")

# Area variables.
var start_point = preload("res://scenes/areas/forgotten_isles/start_point.tscn")

signal scene_transition_started
signal scene_transition_completed

# Sets the processing mode to always.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

# Starts the game.
func start_game() -> void:
	GameState.reset_game_state()
	transition_to_scene(start_point.resource_path)

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
	transition_to_scene(game_over.resource_path, true, true)

# Quits the game.
func quit_game() -> void:
	get_tree().quit()

# For scene transitions.
func transition_to_scene(scene_path, use_fancy: bool = false, only_wipe_in: bool = false) -> void:
	var fancy_transition_instance = fancy_transition.instantiate()
	var simple_transition_instance = simple_transition.instantiate()
	emit_signal("scene_transition_started")

	if use_fancy:
		get_tree().root.add_child(fancy_transition_instance)
		await fancy_transition_instance.play_in()
	else:
		get_tree().root.add_child(simple_transition_instance)

	await get_tree().create_timer(0.4).timeout
	get_tree().change_scene_to_file(scene_path)

	if use_fancy and not only_wipe_in:
		await get_tree().process_frame
		await get_tree().process_frame
		await fancy_transition_instance.play_out()
	elif use_fancy and only_wipe_in:
		await get_tree().process_frame
		await get_tree().process_frame
		fancy_transition_instance.queue_free()
	else:
		simple_transition_instance.queue_free()
