extends CanvasLayer

@onready var weapon_display: TextureRect = $"Weapon Display"

# Function to update the weapon icon.
func update_weapon_icon(weapon_name: String) -> void:
	weapon_display.update_weapon_icon(weapon_name)
