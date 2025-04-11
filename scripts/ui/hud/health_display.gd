# health_display.gd
extends Control

@export var bar_active: Texture2D
@export var bar_inactive: Texture2D
@export var numbers: Array[Texture2D]  # [0, 1, 2, 3, 4, 5, 6]

@onready var all_bars := [
	$Bar1, $Bar2, $Bar3, $Bar4, $Bar5, $Bar6
]

@onready var number_display := $Number

func _ready():
	# Initialize with current values
	update_max_health(GameState.max_health)
	update_health(GameState.current_health)

func update_health(new_health: int):
	# Update bars
	for i in range(all_bars.size()):
		if all_bars[i].visible:
			all_bars[i].texture = bar_active if new_health > i else bar_inactive
	
	# Update number display
	var num_index = clamp(new_health, 0, numbers.size() - 1)
	number_display.texture = numbers[num_index]

func update_max_health(new_max: int):
	for i in range(all_bars.size()):
		all_bars[i].visible = i < new_max
	update_health(GameState.current_health)
