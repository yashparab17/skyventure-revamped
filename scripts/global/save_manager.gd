extends Node

const SAVE_PATH = "user://savegame.tres"

func save_game() -> void:
	var current_scene = get_tree().current_scene.scene_file_path
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		push_error("No player found in scene for saving!")
		return
	
	var save_data = SaveGame.new()
	save_data.scene_path = current_scene
	save_data.player_position = player.global_position
	save_data.player_health = GameState.current_health
	save_data.score = GameState.score
	save_data.unlocked_weapons = GameState.get_unlocked_weapon_names()
	save_data.current_weapon = GameState.current_weapon_name
	
	var error = ResourceSaver.save(save_data, SAVE_PATH)
	if error != OK:
		push_error("Failed to save game: ", error)
	else:
		print("Game saved successfully at: ", SAVE_PATH)

func load_game() -> bool:
	if not ResourceLoader.exists(SAVE_PATH):
		push_warning("No save file found at path: ", SAVE_PATH)
		return false
	
	var save_data = load(SAVE_PATH) as SaveGame
	if not save_data:
		push_error("Failed to load save data!")
		return false
	
	if save_data.scene_path:
		# Directly store the loaded data in GameState
		GameState.current_health = save_data.player_health
		GameState.score = save_data.score
		GameState.pending_player_position = save_data.player_position
		
		# Unlock weapons before switching to maintain state
		for weapon_name in save_data.unlocked_weapons:
			GameState.unlock_weapon(weapon_name)
		
		# Switch to saved weapon if available
		if save_data.current_weapon != "":
			for i in GameState.weapons.size():
				if GameState.weapons[i].name == save_data.current_weapon:
					GameState.switch_weapon(i)
					break
		
		# Change scene
		var error = get_tree().change_scene_to_file(save_data.scene_path)
		if error != OK:
			push_error("Failed to load scene: ", save_data.scene_path)
			GameState.reset_game_state()
			return false
		
		# Wait for scene to load and position player
		await get_tree().process_frame
		position_player()
		return true
	
	return false

func position_player() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player and GameState.pending_player_position != Vector2.INF:
		player.global_position = GameState.pending_player_position
		GameState.pending_player_position = Vector2.INF
	print("Game loaded successfully!")
