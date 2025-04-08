extends Node2D

# Preloading music.
@onready var area_music = preload("res://assets/music/duvet.mp3")

# Called when the area loads in.
func _ready() -> void:
	# Plays the appropriate music.
	MusicManager.play_music(area_music)
