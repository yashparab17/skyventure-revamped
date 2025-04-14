extends AnimatedSprite2D

# Checks if the player is in the interactable area.
var player_in_area: bool = false
var player_ref: Node2D = null

# Called when the player enters the area.
func _on_interactable_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = true
		player_ref = body

# Called when the player leaves the area.
func _on_interactable_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = false
		player_ref = null

# Checks for interact state.
func _process(delta: float) -> void:
	if player_in_area:
		if player_ref and player_ref.current_state == player_ref.States.INTERACT:
			save_game()

# Saves the game.
func save_game() -> void:
	SaveManager.save_game()
	
	var cutscene_page = [
			{
				"text": "Game saved!",
			},
		]

	var cutscene = preload("res://scenes/ui/cutscenes/paused_cutscene.tscn").instantiate()
	get_tree().root.add_child(cutscene)
	
	await cutscene.ready_to_start_cutscene
	cutscene.start_cutscene(cutscene_page)
