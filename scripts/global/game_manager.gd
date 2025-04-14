extends Node

const MAIN_MENU_PATH = "res://scenes/screens/main_menu.tscn"
const PAUSE_MENU_PATH = "res://scenes/screens/pause_menu.tscn"
const GAME_OVER_PATH = "res://scenes/screens/game_over.tscn"
const SIMPLE_TRANSITION_PATH = "res://scenes/screens/simple_transition.tscn"
const FANCY_TRANSITION_PATH = "res://scenes/screens/fancy_transition.tscn"
const START_POINT_PATH = "res://scenes/areas/forgotten_isles/start_point.tscn"

signal scene_transition_started
signal scene_transition_completed

# Sets the processing mode to always.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

# Starts the game.
func start_game() -> void:
	GameState.reset_game_state()
	transition_to_scene(START_POINT_PATH)

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
		var pause_menu_instance = load(PAUSE_MENU_PATH)
		get_tree().root.add_child(pause_menu_instance)

# Displays game over screen.
func to_game_over() -> void:
	transition_to_scene(GAME_OVER_PATH, true, true)

# Quits the game.
func quit_game() -> void:
	get_tree().quit()

# For scene transitions.
func transition_to_scene(scene_path, use_fancy: bool = false, only_wipe_in: bool = false) -> void:
	emit_signal("scene_transition_started")
	
	var transition_instance
	
	if use_fancy:
		transition_instance = load(FANCY_TRANSITION_PATH).instantiate()
	else:
		transition_instance = load(SIMPLE_TRANSITION_PATH).instantiate()
	
	get_tree().root.add_child(transition_instance)
	
	if use_fancy:
		await transition_instance.play_in()
	else:
		await get_tree().create_timer(0.4).timeout
	
	get_tree().change_scene_to_file(scene_path)
	
	if use_fancy && !only_wipe_in:
		await get_tree().process_frame
		await get_tree().process_frame
		await transition_instance.play_out()
	elif use_fancy && only_wipe_in:
		await get_tree().process_frame
		await get_tree().process_frame
		transition_instance.queue_free()
	else:
		transition_instance.queue_free()
	
	emit_signal("scene_transition_completed")
