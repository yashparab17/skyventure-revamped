extends Node

var max_health: int = 3
var current_health: int

signal on_health_changed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_health = max_health

func decrease_health(health_amount: int):
	current_health -= health_amount
	
	if current_health < 0:
		current_health = 0
	
	print("Decrease health called.")
	print("Current health = ", current_health)
	on_health_changed.emit(current_health)

func increase_health(health_amount: int):
	current_health += health_amount
	
	if current_health > max_health:
		current_health = max_health
		
	print("Increase health called.")
	on_health_changed.emit(current_health)
