extends Node2D

# Variables.
var intro_cutscene_id = "intro_cutscene"

# Preload variables.
@onready var cutscene_scene = preload("res://scenes/ui/cutscenes/cutscene.tscn")
@onready var area_music = preload("res://assets/music/forgotten_isles.mp3")
@onready var player: Node2D = $Player
@onready var hud: CanvasLayer = $HUD

# Called when the area loads in.
func _ready() -> void:
	if not GameState.has_seen_cutscene(intro_cutscene_id):
		await get_tree().create_timer(0.1).timeout
		await _play_intro_cutscene()
	
	# Initialize other systems after cutscene is done.
	_initialize_systems()

func _play_intro_cutscene() -> void:
	hud.hide()
	
	var cutscene_data = [
		{
			"text": "Huh? Where am I?",
			"name": "Victor",
			"portrait": preload("res://assets/textures/ui/cutscene/portraits/player/neutral.png")
		},
		{
			"text": "AND WHY IS THERE A BLASTER STRAPPED TO MY HAND?!",
			"name": "Victor",
			"portrait": preload("res://assets/textures/ui/cutscene/portraits/player/shocked.png")
		},
		{
			"text": "...",
			"name": "Victor",
			"portrait": preload("res://assets/textures/ui/cutscene/portraits/player/flabbergasted.png")
		},
		{
			"text": "On second thought, it's cool.",
			"name": "Victor",
			"portrait": preload("res://assets/textures/ui/cutscene/portraits/player/grinning.png")
		},
		{
			"text": "But it needs some... some sort of module to work.",
			"name": "Victor",
			"portrait": preload("res://assets/textures/ui/cutscene/portraits/player/neutral.png")
		},
		{
			"text": "I better find one and get out of here...",
			"name": "Victor",
			"portrait": preload("res://assets/textures/ui/cutscene/portraits/player/determined.png")
		}
	]
	
	var cutscene_instance = cutscene_scene.instantiate()
	add_child(cutscene_instance)
	
	# Wait for the cutscene to be fully ready.
	await cutscene_instance.ready_to_start_cutscene
	
	cutscene_instance.start_cutscene(cutscene_data, func() -> void: GameState.mark_cutscene_as_seen(intro_cutscene_id), player)
	
	# Wait for cutscene to finish.
	await cutscene_instance.tree_exited
	hud.show()

func _initialize_systems() -> void:
	# Spawn the player accordingly at the correct position.
	SpawnManager.set_player(player)
	SpawnManager.spawn_player()
	print("Player spawned!")

	# Play the appropriate music.
	if not MusicManager.is_playing() or not MusicManager.is_current_music(area_music):
		MusicManager.play_music(area_music)
