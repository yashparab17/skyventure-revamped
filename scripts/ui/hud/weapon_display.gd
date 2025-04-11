# weapon_display.gd
extends Control

@export var weapon_textures: Dictionary = {
	"Star Bullet": preload("res://assets/textures/ui/hud/weapon_display/star_bullet.png"),
	"Fireball": preload("res://assets/textures/ui/hud/weapon_display/fireball.png")
}

@onready var texture_rect := $Texture

func _ready():
	# Initialize with current weapon if available
	if GameState.current_weapon_name != "":
		update_weapon(GameState.current_weapon_name)

func update_weapon(weapon_name: String):
	if weapon_name in weapon_textures:
		texture_rect.texture = weapon_textures[weapon_name]
	else:
		texture_rect.texture = preload("res://assets/textures/ui/hud/weapon_display/empty.png")
