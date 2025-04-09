extends AnimatedSprite2D

# Sound references.
@onready var snd_restore: AudioStreamPlayer2D = $Sounds/Restore

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

# Checks for interact state.
func _process(delta: float) -> void:
	if player_in_area:
		if player_ref and player_ref.current_state == player_ref.States.INTERACT:
			restore_health()

# Restores health.
func restore_health() -> void:
	snd_restore.play()
	GameState.current_health = GameState.max_health

	var cutscene_page = [
			{
				"text": "Restored health!",
			},
		]

	var cutscene = preload("res://scenes/ui/cutscenes/cutscene.tscn").instantiate()
	get_tree().root.add_child(cutscene)
	cutscene.start_cutscene(cutscene_page)
