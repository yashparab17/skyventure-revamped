extends Control

# Export variables for the textures.
@export var bar_active: Texture2D
@export var bar_inactive: Texture2D
@export var numbers: Array[Texture2D]  # [0, 1, 2, 3, 4, 5, 6]

@onready var all_bars := [
	$Bar1, $Bar2, $Bar3, $Bar4, $Bar5, $Bar6
]

@onready var number_display := $Number

func _ready():
	GameState.connect("health_changed", update_health)
	GameState.connect("max_health_changed", update_max_health)

	# Optional: init both right away
	update_health(GameState.current_health)
	update_max_health(GameState.max_health)

# Updates health accordingly when the signal is received.
func update_health(new_health: int):
	# Updates bars using a for loop.
	for i in range(all_bars.size()):
		if all_bars[i].visible:
			all_bars[i].texture = bar_active if new_health > i else bar_inactive
	
	# Updates number display using an array of textures.
	var num_index = clamp(new_health, 0, numbers.size() - 1)
	number_display.texture = numbers[num_index]

# Updates max health accordingly when the signal is received.
func update_max_health(new_max: int):
	for i in range(all_bars.size()):
		all_bars[i].visible = i < new_max
	update_health(GameState.max_health)
