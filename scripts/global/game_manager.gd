extends Node

# Scene variables - UI
var main_menu = preload("res://scenes/ui/screens/main_menu.tscn")
var cutscene = preload("res://scenes/ui/cutscenes/cutscene.tscn")
var module_pickup_cutscene = preload("res://scenes/ui/cutscenes/module_pickup_cutscene.tscn")

# Scene variables - Area
var area_1 = preload("res://scenes/areas/area_1.tscn")

# Sets the processing mode to always
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

# Starts the game.
func start_game() -> void:
	transition_to_scene(area_1.resource_path)
	ScoreManager.reset_score()

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
	if get_tree().paused:
		get_tree().paused = false
		MusicManager.resume_music()
	else:
		get_tree().paused = true
		MusicManager.pause_music()

# Quits the game.
func quit_game() -> void:
	get_tree().quit()

# For scene transitions.
func transition_to_scene(scene_path) -> void:
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file(scene_path)
