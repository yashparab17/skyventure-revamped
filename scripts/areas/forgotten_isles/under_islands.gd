extends Node2D

var cutscene_1_id = "cutscene_1"

# Preload variables.
@onready var cutscene_scene = preload("res://scenes/ui/cutscenes/cutscene.tscn")

# Node references.
@onready var player: Node2D = $Player
@onready var map_player = $Player
@onready var collidable = $Tiles/Collidable
@onready var hud = $HUD
@onready var cutscene_1_trigger = $Triggers/Cutscene1Trigger

# Preloading music.
@onready var area_music = preload("res://assets/music/forgotten_isles.mp3")

# Called when the area loads in.
func _ready() -> void:
	if GameState.has_seen_cutscene(cutscene_1_id) or GameState.has_weapon("Star Bullet"):
		cutscene_1_trigger.queue_free()
		
	# Spawn the player accordingly at the correct position.
	var player = get_node("Player")
	SpawnManager.set_player(player)
	SpawnManager.spawn_player()
	print("Player spawned!")
	
	# Play the appropriate music.
	if not MusicManager.is_playing() or not MusicManager.is_current_music(area_music):
		MusicManager.play_music(area_music)
	
	# Generate map.
	MapManager.generate_map_from_tilemap_layer(collidable)
	hud.emit_signal("minimap_setup_requested", map_player, collidable)

func play_cutscene() -> void:
	var cutscene_data = [
		{
			"text": "There goes my plan of escaping...",
			"name": "Victor",
			"portrait": preload("res://assets/textures/ui/cutscene/portraits/player/determined.png")
		},
		{
			"text": "Nevermind, I overreacted.",
			"name": "Victor",
			"portrait": preload("res://assets/textures/ui/cutscene/portraits/player/grinning.png")
		},
		{
			"text": "It looks destroyable. Maybe I should try the other side...",
			"name": "Victor",
			"portrait": preload("res://assets/textures/ui/cutscene/portraits/player/neutral.png")
		},
	]
	
	var cutscene_instance = cutscene_scene.instantiate()
	add_child(cutscene_instance)
	
	# Wait for the cutscene to be fully ready.
	await cutscene_instance.ready_to_start_cutscene
	
	cutscene_instance.start_cutscene(cutscene_data, func() -> void: GameState.mark_cutscene_as_seen(cutscene_1_id), player)
	
	# Wait for cutscene to finish.
	await cutscene_instance.tree_exited
	cutscene_1_trigger.queue_free()
	hud.show()

func _on_cutscene_1_trigger_body_entered(body: Node2D) -> void:
	play_cutscene()
