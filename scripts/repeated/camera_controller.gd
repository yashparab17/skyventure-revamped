extends Camera2D

@export var vertical_aim_offset := 64

var player: Node2D

func _ready():
	var root = get_tree().current_scene
	player = find_node_recursive(root, "Player") as Node2D

	SpawnManager.connect("player_spawned", Callable(self, "_on_player_spawned"))

	if not player:
		push_warning("Camera: Player node not found!")

func _on_player_spawned():
	global_position = player.global_position
	position_smoothing_enabled = false
	await get_tree().process_frame
	position_smoothing_enabled = true

func _process(delta):
	if not player:
		return

	var target_pos = player.global_position

	if Input.is_action_pressed("aim_up"):
		target_pos.y -= vertical_aim_offset
	elif Input.is_action_pressed("aim_down") and not player.is_on_floor():
		target_pos.y += vertical_aim_offset

	global_position = target_pos

# Recursive node search
func find_node_recursive(current: Node, name: String) -> Node:
	if current.name == name:
		return current
	for child in current.get_children():
		if child is Node:
			var result = find_node_recursive(child, name)
			if result:
				return result
	return null
