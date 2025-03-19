extends Node2D

@onready var player: CharacterBody2D = $"Player Stuff/Player"
@onready var hud: CanvasLayer = $"Player Stuff/HUD"

func _ready() -> void:
	player.connect("weapon_switched", hud.update_weapon_icon)
	Global.hud = hud
	Global.show_hud()
