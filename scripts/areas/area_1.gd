extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $HUD
@onready var cutscene_1_trigger = $Triggers/Cutscene1Trigger

func _ready() -> void:
	# HUD signals.
	player.connect("weapon_switched", hud.update_weapon_icon)
	Global.hud = hud
	Global.show_hud()
	
	# Plays the music.
	var area_music = preload("res://assets/music/area_1/duvet.mp3")
	MusicManager.play_music(area_music)

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
