extends Node2D

@export var barActive : Texture2D
@export var barInactive : Texture2D
@export var number_3 : Texture2D
@export var number_2 : Texture2D
@export var number_1 : Texture2D
@export var number_0 : Texture2D

@onready var bar_1 = $Bar1
@onready var bar_2 = $Bar2
@onready var bar_3 = $Bar3
@onready var number = $Number

func _ready() -> void:
	HealthManager.on_health_changed.connect(on_player_health_changed)

func on_player_health_changed(player_current_health: int):
	if player_current_health == 3:
		bar_3.texture = barActive
		number.texture = number_3
	elif player_current_health < 3:
		bar_3.texture = barInactive
		number.texture = number_2
		
	if player_current_health == 2:
		bar_2.texture = barActive
		number.texture = number_2
	elif player_current_health < 2:
		bar_2.texture = barInactive
		number.texture = number_1
		
	if player_current_health == 1:
		bar_1.texture = barActive
		number.texture = number_1
	elif player_current_health < 1:
		bar_1.texture = barInactive
		number.texture = number_0
