extends Node

# Preloading essential scenes.
var scenes_to_preload = [
	# Starting area.
	preload("res://scenes/areas/forgotten_isles/start_point.tscn"),
	# Characters.
	preload("res://scenes/characters/enemies/critter.tscn"),
	preload("res://scenes/characters/enemies/flying_roach.tscn"),
	preload("res://scenes/characters/enemies/roach.tscn"),
	preload("res://scenes/characters/player/player.tscn"),
	# Projectiles.
	preload("res://scenes/projectiles/star_bullet.tscn"),
	# Screens.
	preload("res://scenes/screens/fancy_transition.tscn"),
	preload("res://scenes/screens/game_over.tscn"),
	preload("res://scenes/screens/introduction.tscn"),
	preload("res://scenes/screens/leaderboard.tscn"),
	preload("res://scenes/screens/main_menu.tscn"),
	preload("res://scenes/screens/pause_menu.tscn"),
	preload("res://scenes/screens/simple_transition.tscn"),
	# UI.
	preload("res://scenes/ui/cutscenes/cutscene.tscn"),
	preload("res://scenes/ui/cutscenes/module_pickup_cutscene.tscn"),
	preload("res://scenes/ui/cutscenes/paused_cutscene.tscn"),
	preload("res://scenes/ui/hud/hud.tscn")
]

signal loading_progress(message: String)
signal loading_complete

func start_loading() -> void:
	for scene in scenes_to_preload:
		emit_signal("loading_progress", "Loading: %s" % scene.resource_path.get_file())
		var instance = scene.instantiate()
		instance.free()
		await get_tree().create_timer(0.1).timeout
	
	emit_signal("loading_complete")
