extends AnimatedSprite2D

# The type of module.
@export var module_type: String = "star_bullet"

# Item pickup effect.
@onready var item_pickup = preload("res://scenes/effects/item_pickup.tscn")
@onready var cutscene_scene = preload("res://scenes/ui/cutscenes/module_pickup_cutscene.tscn")

# Sound references.
@onready var snd_pickup = $Sounds/Pickup

# Checks if the player is in the pickup area.
var player_in_area: bool = false

func _on_pickup_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = true

func _on_pickup_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = false

func _process(delta: float) -> void:
	if player_in_area and Input.is_action_pressed("aim_down"):
		pickup_module()

func pickup_module() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		await get_tree().create_timer(0.2)
		player.collect_module(module_type)
		snd_pickup.play()
		visible = false
		
		var cutscene_instance = cutscene_scene.instantiate()
		get_tree().root.add_child(cutscene_instance)
		cutscene_instance.module_name = "Picked up the Star Bullet module!"
		cutscene_instance.module_description = "Allows for the shooting of a star bullet that deals 1 damage."
		cutscene_instance.start_cutscene()
		
		var item_pickup_instance = item_pickup.instantiate() as Node2D
		item_pickup_instance.global_position = global_position
		get_parent().add_child(item_pickup_instance)
		
		queue_free()
