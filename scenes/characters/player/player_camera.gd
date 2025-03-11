extends Camera2D

@export var player: CharacterBody2D
@export var area: Node2D

func _process(delta: float) -> void:
	if player != null:
		global_position = player.global_position
