extends Node

const SAVE_PATH = "user://savegame.tres"

func save_game() -> void:
	# Get current scene information
	var current_scene = get_tree().current_scene.scene_file_path
	
	# Get player node
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		push_error("No player found in scene for saving!")
		return
	
	# Create new save resource
	var save_data = SaveGame.new()
	
	# Populate save data
	save_data.scene_path = current_scene
	save_data.player_position = player.global_position
	save_data.player_health = GameState.current_health
	save_data.score = GameState.score
	
	# Save weapon information
	var unlocked_weapons = PackedStringArray()
	for weapon in player.weapons:
		if weapon.unlocked:
			unlocked_weapons.append(weapon.name)
	save_data.unlocked_weapons = unlocked_weapons
	
	save_data.current_weapon = player.current_weapon.name if player.current_weapon else ""
	
	# Save the resource
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
	
	# Load the saved scene
	if save_data.scene_path:
		# Store the save data we need after scene change
		var saved_position = save_data.player_position
		var saved_weapons = save_data.unlocked_weapons
		var saved_current_weapon = save_data.current_weapon
		
		# Change scene and wait for it to be ready
		var error = get_tree().change_scene_to_file(save_data.scene_path)
		if error != OK:
			push_error("Failed to load scene: ", save_data.scene_path)
			return false
		
		# Wait for the scene to fully load
		await get_tree().create_timer(0.1).timeout
		
		# Restore game state
		GameState.current_health = save_data.player_health
		GameState.score = save_data.score
		
		# Find player in the new scene - may need multiple attempts
		var player = null
		for i in range(5): # Try 5 times with small delays
			player = get_tree().get_first_node_in_group("player")
			if player:
				break
			await get_tree().create_timer(0.1).timeout
		
		if not player:
			push_error("No player found in loaded scene after multiple attempts!")
			return false
		
		# Restore player position
		player.global_position = saved_position
		
		# Restore weapons
		for weapon in player.weapons:
			weapon.unlocked = saved_weapons.has(weapon.name)
		
		# Restore current weapon
		if saved_current_weapon:
			for i in range(player.weapons.size()):
				if player.weapons[i].name == saved_current_weapon:
					player.switch_weapon(i)
					break
		
		print("Game loaded successfully!")
		return true
	
	return false
