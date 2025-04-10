extends Node

# Health signals.
signal health_changed(new_health)
signal max_health_changed(new_max_health)

# Score signals.
signal score_changed(new_score)
signal score_reset()

# Weapon signals.
signal weapon_changed(new_weapon)

# A list for unlocked weapons.
var unlocked_weapons: Array[String] = []

# A dictionary for pending spawn data.
var pending_spawn_data := {
	"scene": "",
	"spawn_id": ""
}

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

# Health methods.
func decrease_health(amount: int) -> void:
	current_health -= amount

func increase_health(amount: int) -> void:
	current_health += amount

func reset_health() -> void:
	current_health = max_health

# Saves player position on save.
var pending_player_position: Vector2 = Vector2.INF

# Score methods.
func increment_score(amount: int) -> void:
	score += amount

# Resets score.
func reset_score() -> void:
	score = 0
	emit_signal("score_reset")

# Sets pending spawn data.
func set_pending_spawn(scene: String, spawn_id: String) -> void:
	pending_spawn_data["scene"] = scene
	pending_spawn_data["spawn_id"] = spawn_id

# Consumes pending spawn id.
func consume_pending_spawn_id() -> String:
	var id = pending_spawn_data["spawn_id"]
	pending_spawn_data["spawn_id"] = ""
	return id

# Full game reset.
func reset_game_state():
	reset_health()
	reset_score()
	current_weapon = ""
