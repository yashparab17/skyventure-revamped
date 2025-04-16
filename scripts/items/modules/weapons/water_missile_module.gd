extends AnimatedSprite2D

# The type of module.
@export var module_type: String = "Water Missile"

# Item pickup effect.
@onready var item_pickup = preload("res://scenes/effects/item_pickup.tscn")
@onready var cutscene_scene = preload("res://scenes/ui/cutscenes/module_pickup_cutscene.tscn")

# Node references.
@onready var light: PointLight2D = $Light

# Sound references.
@onready var snd_pickup: AudioStreamPlayer2D = $Sounds/Pickup

# Score variable.
var score: int = 1000

# Checks if the player is in the pickup area.
var player_in_area: bool = false
var player_ref: Node2D = null

func _ready() -> void:
	if GameState.has_weapon("Water Missile"):
		queue_free()

func _on_pickup_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = true
		player_ref = body

func _on_pickup_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = false
		player_ref = null

func _process(delta: float) -> void:
	animate_light()
	if player_in_area:
		if player_ref and player_ref.current_state == player_ref.States.INTERACT:
			pickup_module()

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

func pickup_module() -> void:
	if !player_ref:
		return

	var player = get_tree().get_first_node_in_group("player")
	if player:
		await get_tree().create_timer(0.2)
		GameState.unlock_weapon(module_type)
		GameState.increment_score(score)
		snd_pickup.play()
		visible = false

		var hud = get_tree().get_first_node_in_group("hud")
		if hud:
			hud.visible = false

		var cutscene_instance = cutscene_scene.instantiate()
		get_tree().root.add_child(cutscene_instance)
		cutscene_instance.module_name = "Picked up the Water Missile module!"
		cutscene_instance.module_description = "Fires a powerful water missile that deals 3 damage."
		cutscene_instance.start_cutscene()

		var item_pickup_instance = item_pickup.instantiate() as Node2D
		item_pickup_instance.global_position = global_position
		get_parent().add_child(item_pickup_instance)

		await cutscene_instance.cutscene_finished

		if hud:
			hud.visible = true

		queue_free()
