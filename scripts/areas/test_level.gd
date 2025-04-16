extends Node2D

# Preloading music.
@onready var area_music = preload("res://assets/music/test_level.mp3")

# Called when the area loads in.
func _ready() -> void:
	# Play the appropriate music.
	if not MusicManager.is_playing() or not MusicManager.is_current_music(area_music):
		MusicManager.play_music(area_music)
