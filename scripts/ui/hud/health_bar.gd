extends Node2D

# Textures for the health bar and number display.
@export var barActive: Texture2D
@export var barInactive: Texture2D
@export var number_3: Texture2D
@export var number_2: Texture2D
@export var number_1: Texture2D
@export var number_0: Texture2D

# Node references for the health bar and number display.
@onready var bar_1 = $Bar1
@onready var bar_2 = $Bar2
@onready var bar_3 = $Bar3
@onready var number = $Number

func _ready() -> void:
	# Connect the health bar to the player's health changed signal.
	HealthManager.on_health_changed.connect(on_player_health_changed)

# Updates the health bar and number display based on the player's current health.
func on_player_health_changed(player_current_health: int) -> void:
	# If the player has 3 health, make the third bar active and display the number 3.
	if player_current_health == 3:
		bar_3.texture = barActive
		number.texture = number_3
	# If the player has less than 3 health, make the third bar inactive and display the number 2.
	elif player_current_health < 3:
		bar_3.texture = barInactive
		number.texture = number_2
		
	# If the player has 2 health, make the second bar active and display the number 2.
	if player_current_health == 2:
		bar_2.texture = barActive
		number.texture = number_2
	# If the player has less than 2 health, make the second bar inactive and display the number 1.
	elif player_current_health < 2:
		bar_2.texture = barInactive
		number.texture = number_1
		
	# If the player has 1 health, make the first bar active and display the number 1.
	if player_current_health == 1:
		bar_1.texture = barActive
		number.texture = number_1
	# If the player has less than 1 health, make the first bar inactive and display the number 0.
	elif player_current_health < 1:
		bar_1.texture = barInactive
		number.texture = number_0
