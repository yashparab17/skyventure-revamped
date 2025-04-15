extends Node

# Reference for the player.
var player: Node = null

signal player_spawned

# Sets player in the manager.
func set_player(p: Node):
	player = p

# Spawns the player at the correct spawn ID.
func spawn_player():
	# Get spawn ID.
	var spawn_id = GameState.consume_pending_spawn_id()
	var spawn_point = find_spawn_point_by_id(spawn_id)

	if player == null:
		return

	if spawn_id == "":
		emit_signal("player_spawned")
		return

	# Spawn player.
	if spawn_point:
		player.global_position = spawn_point.global_position
		print("Emitting player_spawned signal...")
		emit_signal("player_spawned")
	else:
		print("SpawnManager: Could not find spawn point with ID: ", spawn_id)

# Finds a spawn point by ID.
func find_spawn_point_by_id(id: String) -> Node2D:
	# Get all spawn points.
	for node in get_tree().get_nodes_in_group("spawn_points"):
		# Gets the specified spawn point with the ID.
		if "spawn_id" in node and node.spawn_id == id:
			return node
	return null
