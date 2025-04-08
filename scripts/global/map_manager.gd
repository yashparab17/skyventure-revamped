extends Node

var current_map_data: Image
var current_minimap_texture: ImageTexture
var map_origin := Vector2i.ZERO  # NEW: Origin of the minimap image (after padding)

signal minimap_ready

func generate_map_from_tilemap_layer(layer: TileMapLayer):
	var used_rect = layer.get_used_rect()
	var padding = 16
	used_rect.position -= Vector2i(padding, padding)
	used_rect.size += Vector2i(padding * 2, padding * 2)

	map_origin = used_rect.position  # Store this for offsetting later

	var width = used_rect.size.x
	var height = used_rect.size.y

	var img = Image.create(width, height, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	for cell in layer.get_used_cells():
		var local_x = cell.x - map_origin.x
		var local_y = cell.y - map_origin.y
		img.set_pixel(local_x, local_y, Color(1, 1, 1, 1))

	current_map_data = img
	current_minimap_texture = ImageTexture.create_from_image(img)

	emit_signal("minimap_ready")
