extends Control

# Export variables for the textures.
@export var bar_active: Texture2D
@export var bar_inactive: Texture2D
@export var numbers: Array[Texture2D]  # [0, 1, 2, 3]

@onready var bars := [$Bar1, $Bar2, $Bar3]
@onready var number_display := $Number

# Updates health accordingly when the signal is received.
func update_health(new_health: int):
	# Updates bars using a for loop.
	for i in range(bars.size()):
		bars[i].texture = bar_active if new_health > i else bar_inactive
	
	# Updates number display using an array of textures.
	var num_index = clamp(new_health, 0, numbers.size() - 1)
	number_display.texture = numbers[num_index]
