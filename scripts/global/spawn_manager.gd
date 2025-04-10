extends Node

var player: Node = null

func set_player(p: Node):
	player = p

func spawn_player():
	var spawn_id = GameState.consume_pending_spawn_id()
	print("SpawnManager: Spawn ID received: ", spawn_id)
	if spawn_id == "" or player == null:
		print("SpawnManager: No valid spawn ID or player is null")
		return
	
	var spawn_point = find_spawn_point_by_id(spawn_id)
	if spawn_point:
		print("SpawnManager: Found spawn point: ", spawn_point.name)
		player.global_position = spawn_point.global_position
	else:
		print("SpawnManager: Could not find spawn point with ID: ", spawn_id)

func find_spawn_point_by_id(id: String) -> Node2D:
	for node in get_tree().get_nodes_in_group("spawn_points"):
		if "spawn_id" in node and node.spawn_id == id:
			return node
	return null
