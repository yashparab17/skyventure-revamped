extends Node

var max_health: int = 5
var current_health: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func decrease_health(health_amount: int):
	current_health -= health_amount
	
	if current_health < 0:
		current_health = 0
	
	print("Decrease health called.")
		
func increase_health(health_amount: int):
	current_health += health_amount
	
	if current_health > max_health:
		current_health = max_health
		
	print("Increase health called.")
