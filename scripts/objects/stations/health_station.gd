extends AnimatedSprite2D

# Node references.
@onready var light: PointLight2D = $Light

# Sound references.
@onready var snd_restore: AudioStreamPlayer = $Sounds/Restore

# Checks if the player is in the interactable area.
var player_in_area: bool = false
var player_ref: Node2D = null

func _on_interactable_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = true
		player_ref = body

func _on_interactable_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = false
		player_ref = null

# Runs every frame.
func _process(delta: float) -> void:
	animate_light()
	if player_in_area:
		if player_ref and player_ref.current_state == player_ref.States.INTERACT:
			restore_health()

# Animates light according to the frame.
func animate_light() -> void:
	var current_frame = frame
	match animation:
		"blink":
			match current_frame:
				0:
					light.energy = 0.25
				1:
					light.energy = 1.0
				2:
					light.energy = 0.5
				3:
					light.energy = 1.0
				4:
					light.energy = 0.5

# Restores health.
func restore_health() -> void:
	SoundManager.play_sound(snd_restore.stream)
	GameState.current_health = GameState.max_health

	var cutscene_page = [
			{
				"text": "Restored health!",
			},
		]

	var cutscene = preload("res://scenes/ui/cutscenes/paused_cutscene.tscn").instantiate()
	get_tree().root.add_child(cutscene)
	
	await cutscene.ready_to_start_cutscene
	cutscene.start_cutscene(cutscene_page)
