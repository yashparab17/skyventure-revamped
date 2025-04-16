extends Node2D

# Node references.
@onready var map_player = $Player
@onready var collidable = $Tiles/Collidable
@onready var hud = $HUD
@onready var star_bullet_module = $Objects/StarBulletModule

# Preloading music.
@onready var area_music = preload("res://assets/music/pulse.mp3")

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
	
	if GameState.has_weapon("Star Bullet"):
		star_bullet_module.queue_free()
