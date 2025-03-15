extends Node2D

# The type of module.
@export var module_type: String = "star_bullet"

func _on_pickup_area_body_entered(body: Node2D) -> void:
	# Check if the body that entered is the player.
	if body.is_in_group("player"):
		# Call the player's method to collect the module.
		body.collect_module(module_type)
		# Remove the module from the scene.
		queue_free()
