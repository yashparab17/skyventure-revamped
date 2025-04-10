extends Node2D

# Called when the area loads in.
func _ready() -> void:
	# Spawns the player accordingly at the correct position.
	var player = get_node("Player")
	SpawnManager.set_player(player)

	if GameState.pending_spawn_data["spawn_id"] != "":
		SpawnManager.spawn_player()
	else:
		print("No pending spawn — using default scene placement.")
