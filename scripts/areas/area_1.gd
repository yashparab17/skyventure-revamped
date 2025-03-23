extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $HUD

func _ready() -> void:
	# HUD signals.
	player.connect("weapon_switched", hud.update_weapon_icon)
	Global.hud = hud
	Global.show_hud()
	
	# Plays the music.
	var area_music = preload("res://assets/music/area_1/duvet.mp3")
	MusicManager.play_music(area_music, -20.0)
