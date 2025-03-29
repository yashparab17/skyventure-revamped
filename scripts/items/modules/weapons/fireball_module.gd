extends AnimatedSprite2D

# The type of module.
@export var module_type: String = "fireball"

# Item pickup effect.
@onready var item_pickup = preload("res://scenes/effects/item_pickup.tscn")
@onready var cutscene_scene = preload("res://scenes/ui/module_pickup_cutscene.tscn")

# Sound references.
@onready var snd_pickup = $Sounds/Pickup

func _on_pickup_area_body_entered(body: Node2D) -> void:
	# Check if the body that entered is the player.
	if body.is_in_group("player"):
		# Call the player's method to collect the module.
		body.collect_module(module_type)
		snd_pickup.play()
		visible = false
		
		# Instantiate the cutscene and add it to the scene tree.
		var cutscene_instance = cutscene_scene.instantiate()
		get_tree().root.add_child(cutscene_instance)
		
		# Access the CutsceneUI node and set its properties.
		var cutscene_ui = cutscene_instance.get_node("CutsceneUI")
		cutscene_ui.module_name = "Picked up the Fireball module!"
		cutscene_ui.module_description = "Allows for the shooting of a bouncing fireball that deals 2 damage."
		cutscene_ui.start_cutscene()
		
		# Spawn the item pickup effect.
		var item_pickup_instance = item_pickup.instantiate() as Node2D
		item_pickup_instance.global_position = global_position
		get_parent().add_child(item_pickup_instance)
		
		# Remove the module from the scene.
		queue_free()
