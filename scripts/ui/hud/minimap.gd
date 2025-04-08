extends Control

@onready var display_rect: TextureRect = $Display
@onready var player_indicator: TextureRect = $PlayerIndicator

@export var player: Node2D
@export var tilemap_layer: TileMapLayer

var map_offset = Vector2.ZERO

func _ready():
	MapManager.minimap_ready.connect(_on_minimap_ready)

	# In case it's already ready when this script runs:
	if MapManager.current_minimap_texture:
		_on_minimap_ready()

func _on_minimap_ready():
	if not player or not tilemap_layer:
		# Wait until they're assigned, then try again next frame
		await get_tree().process_frame
		_on_minimap_ready()
		return

	display_rect.texture = MapManager.current_minimap_texture
	print("Minimap texture set.")
	print("Minimap assigned tilemap:", tilemap_layer)
	print("Minimap assigned player:", player)
	_update_offset()

func _process(_delta):
	_update_offset()

func _update_offset():
	if not player or not tilemap_layer:
		return

	var tile_pos = tilemap_layer.local_to_map(player.global_position)
	var relative_pos = Vector2(tile_pos - MapManager.map_origin)

	map_offset = relative_pos - size / 2.0

	# Clamp to the texture size
	var display_size = MapManager.current_minimap_texture.get_size()
	map_offset.x = clamp(map_offset.x, 0, display_size.x - size.x)
	map_offset.y = clamp(map_offset.y, 0, display_size.y - size.y)
	
	player_indicator.position = (Vector2(tile_pos - MapManager.map_origin)) - map_offset - player_indicator.size / 2.0

	display_rect.position = -map_offset
