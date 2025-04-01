extends CanvasLayer

# Node references.
@onready var weapon_display: TextureRect = $"Weapon Display"
@onready var score_display: Control = $"Score Display"

func _ready():
	# Connect to the signals.
	Signals.connect("weapon_switched", _on_weapon_switched)
	Signals.connect("score_updated", _on_score_updated)
	Signals.connect("score_reset", _on_score_reset)

# Handles score updates.
func _on_score_updated(new_score: int) -> void:
	score_display.update_score(new_score)

# Handles score reset.
func _on_score_reset() -> void:
	score_display.update_score(0)
	
# Handles weapon switching.
func _on_weapon_switched(weapon_name: String) -> void:
	update_weapon_icon(weapon_name)

# Updates the weapon icon.
func update_weapon_icon(weapon_name: String) -> void:
	weapon_display.update_weapon_icon(weapon_name)
