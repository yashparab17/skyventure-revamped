extends Node

# Reference for the player.
var player: Node = null

# Sets player in the manager.
func set_player(p: Node):
	player = p

# Spawns the player at the correct spawn ID.
func spawn_player():
	# Get spawn ID.
	var spawn_id = GameState.consume_pending_spawn_id()
	
	# Check if spawn id or player exists. If they don't, then return.
	if spawn_id == "" or player == null:
		return
	
	# Find spawn point.
	var spawn_point = find_spawn_point_by_id(spawn_id)

	# Spawn player.
	if spawn_point:
		player.global_position = spawn_point.global_position
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
