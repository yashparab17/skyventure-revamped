extends Node2D

# Cutscene variables.
var intro_cutscene_id = "intro_cutscene"

# Preload variables.
@onready var cutscene_scene = preload("res://scenes/ui/cutscenes/cutscene.tscn")
@onready var area_music = preload("res://assets/music/forgotten_isles.mp3")

# Node references.
@onready var fake_player: Sprite2D = $FakePlayer
@onready var player: Node2D = $Player
@onready var anim: AnimationPlayer = $Animator
@onready var hud: CanvasLayer = $HUD

# Called when the area loads in.
func _ready() -> void:
	fake_player.hide()
	
	if not GameState.has_seen_cutscene(intro_cutscene_id):
		player.hide()
		fake_player.show()
		hud.hide()
		await get_tree().create_timer(2.0).timeout
		await _animate_fake_player()
	
	# Initialize other systems after cutscene is done.
	_initialize_systems()

# Animates the fake player sprite.
func _animate_fake_player() -> void:
	anim.play("jump")
	SoundManager.play_sound(preload("res://assets/sounds/characters/player/jump.wav"))
	await anim.animation_finished
	fake_player.hide()
	player.show()
	await _play_intro_cutscene()

# Animates the introduction cutscene.
func _play_intro_cutscene() -> void:
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
	fake_player.hide()
	# Spawn the player accordingly at the correct position.
	SpawnManager.set_player(player)
	SpawnManager.spawn_player()
	print("Player spawned!")

	# Play the appropriate music.
	if not MusicManager.is_playing() or not MusicManager.is_current_music(area_music):
		MusicManager.play_music(area_music)
