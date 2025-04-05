extends Node

const SAVE_PATH = "user://savegame.tres"

func save_game(player: Node2D) -> void:
	var save_data = PlayerSaveData.new()
	
	# Save player data
	save_data.player_position = player.global_position
	save_data.current_health = HealthManager.current_health
	save_data.max_health = HealthManager.max_health
	save_data.scene_path = get_tree().current_scene.scene_file_path
	
	# Save weapon data
	save_data.unlocked_weapons = []
	for weapon in player.weapons:
		if weapon.unlocked:
			save_data.unlocked_weapons.append(weapon.name)
	
	if player.current_weapon:
		save_data.current_weapon = player.current_weapon.name
	
	# Save to file
	var error = ResourceSaver.save(save_data, SAVE_PATH)
	if error != OK:
		print("Error saving game: ", error)
	else:
		print("Game saved successfully!")

func load_game() -> PlayerSaveData:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found")
		return null
	
	var save_data = ResourceLoader.load(SAVE_PATH) as PlayerSaveData
	if not save_data:
		print("Error loading save file")
		return null
	
	return save_data

func has_save_data() -> bool:
	return FileAccess.file_exists(SAVE_PATH)
