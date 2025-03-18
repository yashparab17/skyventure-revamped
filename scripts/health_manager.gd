extends Node

# The maximum health points the player can have.
var max_health: int = 3
# The current health points of the player.
var current_health: int

# Emitted when the player's health changes.
signal on_health_changed


func _ready() -> void:
	# Initialize the player's health to the maximum amount.
	current_health = max_health

# Decreases the player's health by the given amount.
func decrease_health(health_amount: int):
	current_health -= health_amount
	
	# If the player's health goes below 0, set it to 0.
	if current_health < 0:
		current_health = 0
	
	# Emit the on_health_changed signal so that other nodes can react to the change in health.
	emit_signal("on_health_changed", current_health)

# Increases the player's health by the given amount.
func increase_health(health_amount: int):
	current_health += health_amount
	
	# If the player's health exceeds the maximum amount, set it to the maximum amount.
	if current_health > max_health:
		current_health = max_health
		
	# Emit the on_health_changed signal so that other nodes can react to the change in health.
	emit_signal("on_health_changed", current_health)