extends Node2D

const MAIN_MENU_PATH = "res://scenes/screens/main_menu.tscn"

# Preload scenes for effects.
var teleport = preload("res://scenes/effects/teleport.tscn")
var block_destroy = preload("res://scenes/effects/block_destroy.tscn")

# Node references.
@onready var fake_player: Sprite2D = $FakePlayer
@onready var anim: AnimationPlayer = $Animator

func _ready() -> void:
	fake_player.visible = false
	await get_tree().create_timer(1.0).timeout
	animate_effect()

func animate_effect() -> void:
	var teleport_instance = teleport.instantiate() as Node2D
	teleport_instance.global_position = global_position + fake_player.position
	get_parent().add_child(teleport_instance)
	
	fake_player.visible = true
	
	await teleport_instance.teleport_finished
	animate_fake_player()

func animate_fake_player() -> void:
	anim.play("fall")
	await anim.animation_finished
	
	var block_destroy_instance = block_destroy.instantiate() as Node2D
	block_destroy_instance.global_position = global_position + fake_player.position
	get_parent().add_child(block_destroy_instance)
	
	anim.play("land")
	await get_tree().create_timer(3.0).timeout
	exit()

func exit() -> void:
	GameManager.transition_to_scene(MAIN_MENU_PATH, true)
