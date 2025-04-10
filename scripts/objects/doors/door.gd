extends Sprite2D

@export var target_scene: String
@export var target_spawn_id: String

# Checks if the player is in the interactable area, and has transitioned.
var player_in_area: bool = false
var player_ref: Node2D = null
var has_transitioned: bool = false

# Called when the player enters the area.
func _on_interactable_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = true
		player_ref = body
		has_transitioned = false

# Called when the player exits the area.
func _on_interactable_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = false
		player_ref = null
		has_transitioned = false

# Called every frame.
func _process(delta: float) -> void:
	# Transition if the player is in the area and hasn't transitioned yet.
	if player_in_area and not has_transitioned:
		# Transition if the player is in the interact state.
		if player_ref and player_ref.current_state == player_ref.States.INTERACT:
			transition()

# Transitions to the target scene.
func transition() -> void:
	has_transitioned = true
	GameState.set_pending_spawn(target_scene, target_spawn_id)
	GameManager.transition_to_scene(target_scene)
