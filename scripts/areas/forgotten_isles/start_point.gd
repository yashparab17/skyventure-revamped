extends Node2D

# Preloading music.
@onready var area_music = preload("res://assets/music/forgotten_isles.mp3")

# Called when the area loads in.
func _ready() -> void:
	# Spawn the player accordingly at the correct position.
	var player = get_node("Player")
	SpawnManager.set_player(player)
	SpawnManager.spawn_player()
	print("Player spawned!")

	# Play the appropriate music.
	if not MusicManager.is_playing() or not MusicManager.is_current_music(area_music):
		MusicManager.play_music(area_music)
