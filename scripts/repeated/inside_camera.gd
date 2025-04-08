extends Camera2D

@export var vertical_aim_offset := 64

var player: Node2D
var tilemap: TileMapLayer

func _ready():
	var root = get_tree().current_scene
	player = find_node_recursive(root, "Player") as Node2D
	tilemap = find_node_recursive(root, "Collidable") as TileMapLayer

	if not player:
		push_warning("CameraController: Player node not found!")
	if not tilemap:
		push_warning("CameraController: Collidable tilemap not found!")

func _process(delta):
	if not player or not tilemap:
		return

	var target_pos = player.global_position

	if Input.is_action_pressed("aim_up"):
		target_pos.y -= vertical_aim_offset
	elif Input.is_action_pressed("aim_down"):
		target_pos.y += vertical_aim_offset

	# Get viewport size
	var screen_size = get_viewport_rect().size
	var half_screen = screen_size * 0.5

	# Get tilemap bounds
	var used_rect = tilemap.get_used_rect()
	var cell_size = tilemap.tile_set.tile_size
	var map_min = tilemap.to_global(used_rect.position * cell_size)
	var map_max = tilemap.to_global((used_rect.position + used_rect.size) * cell_size)

	# Clamp camera position inside map boundaries
	target_pos.x = clamp(target_pos.x, map_min.x + half_screen.x, map_max.x - half_screen.x)
	target_pos.y = clamp(target_pos.y, map_min.y + half_screen.y, map_max.y - half_screen.y)

	global_position = target_pos

# Recursive node search function (like find_node())
func find_node_recursive(current: Node, name: String) -> Node:
	if current.name == name:
		return current
	for child in current.get_children():
		if child is Node:
			var result = find_node_recursive(child, name)
			if result:
				return result
	return null
