extends Camera2D

@export var vertical_aim_offset := 64

var player: Node2D

func _ready():
	var root = get_tree().current_scene
	player = find_node_recursive(root, "Player") as Node2D

	if not player:
		push_warning("OutdoorCamera: Player node not found!")

func _process(delta):
	if not player:
		return

	var target_pos = player.global_position

	if Input.is_action_pressed("aim_up"):
		target_pos.y -= vertical_aim_offset
	elif Input.is_action_pressed("aim_down"):
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
