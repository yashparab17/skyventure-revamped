extends AnimatedSprite2D

# Item pickup effect.
@onready var item_pickup = preload("res://scenes/effects/item_pickup.tscn")
@onready var cutscene_scene = preload("res://scenes/ui/cutscenes/module_pickup_cutscene.tscn")

# Node references.
@onready var light: PointLight2D = $Light

# Sound references.
@onready var snd_pickup: AudioStreamPlayer2D = $Sounds/Pickup

# Checks if the player is in the pickup area.
var player_in_area: bool = false
var player_ref: Node2D = null

# Called when the player enters the area.
func _on_pickup_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = true
		player_ref = body

# Called when the player exits the area.
func _on_pickup_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = false
		player_ref = null

# Runs every frame.
func _process(delta: float) -> void:
	animate_light()
	if player_in_area:
		if player_ref and player_ref.current_state == player_ref.States.INTERACT:
			pickup_module()

# Animates light according to the frame.
func animate_light() -> void:
	var current_frame = frame
	match animation:
		"flash":
			match current_frame:
				0:
					light.energy = 0.25
				1:
					light.energy = 0.5
				2:
					light.energy = 1.0
				3:
					light.energy = 0.5

# Picks the module up and adds it to the player.
func pickup_module() -> void:
	if !player_ref:
		return
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		print("Old max health: ", GameState.max_health)
		GameState.max_health += 1
		GameState.current_health = GameState.max_health
		print("New max health: ", GameState.max_health)
		snd_pickup.play()
		visible = false
		
		var cutscene_instance = cutscene_scene.instantiate()
		get_tree().root.add_child(cutscene_instance)
		cutscene_instance.module_name = "Picked up a health module!"
		cutscene_instance.module_description = "Increased your max health by 3."
		cutscene_instance.start_cutscene()
		
		var item_pickup_instance = item_pickup.instantiate() as Node2D
		item_pickup_instance.global_position = global_position
		get_parent().add_child(item_pickup_instance)
		
		queue_free()
