extends Node2D

@onready var hud = $HUD
@onready var player = $Player
@onready var ground_blocks = $Tiles/GroundBlocks
@onready var cutscene_1_trigger = $Triggers/Cutscene1Trigger

func _ready() -> void:
	# Generates map.
	MapManager.generate_map_from_tilemap_layer(ground_blocks)
	hud.emit_signal("minimap_setup_requested", player, ground_blocks)
	# Plays the music.
	var area_music = preload("res://assets/music/duvet.mp3")
	MusicManager.play_music(area_music)

# Called when the player enters the cutscene_1 teigger.
func _on_cutscene_1_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var cutscene_pages = [
			{
				"name": "Victor",
				"text": "Yo what the hell",
				"portrait": preload("res://assets/textures/ui/cutscene/portraits/player/neutral.png"),
			},
			{
				"text": "The wind howls ominously...",
			},
			{
				"name": "Victor",
				"text": "This shi sucks bruh",
				"portrait": preload("res://assets/textures/ui/cutscene/portraits/player/neutral.png"),
			}
		]
		
		var cutscene = preload("res://scenes/ui/cutscenes/cutscene.tscn").instantiate()
		get_tree().root.add_child(cutscene)
		cutscene.start_cutscene(cutscene_pages, Callable(self, "_on_cutscene_1_finished"))

func _on_cutscene_1_finished():
	cutscene_1_trigger.queue_free()
