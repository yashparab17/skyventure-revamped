extends Sprite2D

# Export variables.
@export var target_scene: String
@export var target_spawn_id: String

# Node references.
@onready var snd_enter: AudioStreamPlayer = $Sounds/Enter

# Variables to check if the player is in the interactable area, and has transitioned.
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
			SoundManager.play_sound(snd_enter.stream)
			# Lock player in interact state.
			lock_player()
			transition()

func lock_player() -> void:
	player_ref.can_move = false
	player_ref.velocity = Vector2.ZERO
	player_ref.anim.stop()
	player_ref.current_state = player_ref.States.INTERACT

# Transitions to the target scene.
func transition() -> void:
	has_transitioned = true
	
	# Freeze player animation
	if player_ref:
		player_ref.anim.stop()
	
	GameState.set_pending_spawn(target_scene, target_spawn_id)
	GameManager.transition_to_scene(target_scene, true)

func _on_scene_transition_completed() -> void:
	if player_ref:
		player_ref.enable_movement()
