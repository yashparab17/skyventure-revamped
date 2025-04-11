extends Node2D

@onready var map_player = $Player
@onready var collidable = $Tiles/Collidable
@onready var hud = $HUD

# Called when the area loads in.
func _ready() -> void:
	# Spawns the player accordingly at the correct position.
	var player = get_node("Player")
	SpawnManager.set_player(player)
	SpawnManager.spawn_player()
	print("Player spawned!")
	
	# Generate map.
	MapManager.generate_map_from_tilemap_layer(collidable)
	hud.emit_signal("minimap_setup_requested", map_player, collidable)
