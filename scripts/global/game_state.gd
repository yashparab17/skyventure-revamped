extends Node

# Health signals,
signal health_changed(new_health)
signal max_health_changed(new_max_health)

# Score signals.
signal score_changed(new_score)
signal score_reset()

# Weapon signals.
signal weapon_changed(new_weapon)

var unlocked_weapons: Array[String] = []

# Health properties.
var max_health := 3:
	set(value):
		max_health = value
		emit_signal("max_health_changed", max_health)
		# Ensure current health doesn't exceed new max.
		if current_health > max_health:
			current_health = max_health
			emit_signal("health_changed", current_health)

var current_health := 3:
	set(value):
		current_health = clamp(value, 0, max_health)
		emit_signal("health_changed", current_health)

# Score property.
var score := 0:
	set(value):
		score = max(0, value)
		emit_signal("score_changed", score)

# Weapon property.
var current_weapon := "":
	set(value):
		current_weapon = value
		emit_signal("weapon_changed", current_weapon)

# Saves player position on save.
var pending_player_position: Vector2 = Vector2.INF

# Health methods.
func decrease_health(amount: int) -> void:
	current_health -= amount

func increase_health(amount: int) -> void:
	current_health += amount

func reset_health() -> void:
	current_health = max_health

# Score methods.
func increment_score(amount: int) -> void:
	score += amount

func reset_score() -> void:
	score = 0
	emit_signal("score_reset")

# Full game reset.
func reset_game_state():
	reset_health()
	reset_score()
	current_weapon = ""
