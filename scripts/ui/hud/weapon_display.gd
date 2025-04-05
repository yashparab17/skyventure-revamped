extends Control

# Assign the weapon textures.
@export var weapon_textures: Dictionary = {
	"Star Bullet": preload("res://assets/textures/ui/hud/weapon_display/star_bullet.png"),
	"Fireball": preload("res://assets/textures/ui/hud/weapon_display/fireball.png")
}

# Node reference to the texture.
@onready var texture_rect := $Texture

# Updates texture accordingly when the player switches their weapon.
func update_weapon(weapon_name: String):
	if weapon_name in weapon_textures:
		texture_rect.texture = weapon_textures[weapon_name]
	else:
		texture_rect.texture = preload("res://assets/textures/ui/hud/weapon_display/empty.png")
