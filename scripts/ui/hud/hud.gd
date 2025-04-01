extends CanvasLayer

# Node references.
@onready var weapon_display: TextureRect = $"Weapon Display"
@onready var score_display: Control = $"Score Display"

func _ready():
	# Connect to the ScoreManager's signals.
	ScoreManager.connect("score_updated", _on_score_updated)
	ScoreManager.connect("score_reset", _on_score_reset)

# Handles score updates.
func _on_score_updated(new_score: int) -> void:
	score_display.update_score(new_score)

# Handles score reset.
func _on_score_reset() -> void:
	score_display.update_score(0)

# Function to update the weapon icon.
func update_weapon_icon(weapon_name: String) -> void:
	weapon_display.update_weapon_icon(weapon_name)
