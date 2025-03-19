extends AnimatedSprite2D

# The type of module.
@export var module_type: String = "fireball"

# Item pickup effect.
@onready var item_pickup = preload("res://scenes/effects/item_pickup.tscn")

func _on_pickup_area_body_entered(body: Node2D) -> void:
	# Check if the body that entered is the player.
	if body.is_in_group("player"):
		# Call the player's method to collect the module.
		body.collect_module(module_type)
		
		# Spawn the item pickup effect.
		var item_pickup_instance = item_pickup.instantiate() as Node2D
		item_pickup_instance.global_position = global_position
		get_parent().add_child(item_pickup_instance)
		
		# Remove the module from the scene.
		queue_free()
