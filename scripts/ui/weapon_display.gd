extends TextureRect

# Function to update the weapon icon.
func update_weapon_icon(weapon_name: String) -> void:
	match weapon_name:
		"Star Bullet":
			texture = preload("res://assets/sprites/ui/weapon_display/star_bullet.png")
		"Fireball":
			texture = preload("res://assets/sprites/ui/weapon_display/fireball.png")
