extends Node

# Declare variables to store the current map data and minimap texture.
var current_map_data: Image
var current_minimap_texture: ImageTexture
# Store the origin of the minimap image (after padding).
var map_origin := Vector2i.ZERO

# Declare a signal to indicate when the minimap is ready.
signal minimap_ready

# Function to generate the map from a given tilemap layer.
func generate_map_from_tilemap_layer(layer: TileMapLayer):
	var used_rect = layer.get_used_rect()
	# Define padding around the map.
	# var padding = 16
	# # Adjust the position and size of the used rectangle to include padding.
	# used_rect.position -= Vector2i(padding, padding)
	# used_rect.size += Vector2i(padding * 2, padding * 2)

	# Store the position of the used rectangle as the map origin.
	map_origin = used_rect.position

	# Get the width and height of the used rectangle.
	var width = used_rect.size.x
	var height = used_rect.size.y

	# Create a new image with the specified width, height, and format.
	var img = Image.create(width, height, false, Image.FORMAT_RGBA8)
	# Fill the image with a transparent color.
	img.fill(Color(0, 0, 0, 0))

	# Iterate over each used cell in the tilemap layer.
	for cell in layer.get_used_cells():
		# Calculate the local x and y positions relative to the map origin.
		var local_x = cell.x - map_origin.x
		var local_y = cell.y - map_origin.y
		# Set the pixel at the calculated position to white.
		img.set_pixel(local_x, local_y, Color(1, 1, 1, 1))

	# Assign the created image to the current map data.
	current_map_data = img
	# Create an image texture from the current map data.
	current_minimap_texture = ImageTexture.create_from_image(img)

	# Emit the signal to indicate that the minimap is ready.
	emit_signal("minimap_ready")
