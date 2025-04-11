extends Control

# Node references.
@onready var display_rect: TextureRect = $Display
@onready var player_indicator: TextureRect = $PlayerIndicator

# Export variables.
@export var player: Node2D
@export var tilemap_layer: TileMapLayer

# The offset of the minimap from its top-left corner.
var map_offset = Vector2.ZERO

func _ready():
	# Connect to the signal that indicates the minimap is ready.
	MapManager.minimap_ready.connect(_on_minimap_ready)

	# In case the minimap is already ready when this script runs.
	if MapManager.current_minimap_texture:
		_on_minimap_ready()

func _on_minimap_ready():
	# If tilemap/player not ready, wait and try again safely
	if not player or not tilemap_layer:
		await get_tree().process_frame
		if not is_instance_valid(self): return
		if not player or not tilemap_layer: return
		# Don't recurse, just continue below when ready

	display_rect.texture = MapManager.current_minimap_texture
	print("Minimap texture set.")
	print("Minimap assigned tilemap:", tilemap_layer)
	print("Minimap assigned player:", player)

	_update_offset()


# Update the offset of the minimap every frame to follow the player.
func _process(_delta):
	_update_offset()

func _update_offset():
	# Check if the player and tilemap layer have been assigned.
	if not player or not tilemap_layer:
		return

	# Calculate the position of the player relative to the map origin.
	var tile_pos = tilemap_layer.local_to_map(player.global_position)
	var relative_pos = Vector2(tile_pos - MapManager.map_origin)

	# Calculate the offset of the minimap.
	map_offset = relative_pos - size / 2.0

	# Clamp the offset to the texture size.
	var display_size = MapManager.current_minimap_texture.get_size()
	
	# If display smaller than control, just center it
	if display_size.x <= size.x and display_size.y <= size.y:
		display_rect.position = (size - display_size) / 2
		var scale_factor = display_rect.size / display_size
		player_indicator.position = (Vector2(tile_pos - MapManager.map_origin)) * scale_factor
	else:
		map_offset.x = clamp(map_offset.x, 0, display_size.x - size.x)
		map_offset.y = clamp(map_offset.y, 0, display_size.y - size.y)
		player_indicator.position = (Vector2(tile_pos - MapManager.map_origin)) - map_offset - player_indicator.size / 2.0
		display_rect.position = -map_offset
	
	map_offset.x = clamp(map_offset.x, 0, display_size.x - size.x)
	map_offset.y = clamp(map_offset.y, 0, display_size.y - size.y)

	# Set the position of the player indicator.
	player_indicator.position = (Vector2(tile_pos - MapManager.map_origin)) - map_offset - player_indicator.size / 2.0

	# Set the position of the minimap display.
	display_rect.position = - map_offset
