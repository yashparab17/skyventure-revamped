extends Camera2D

@export var player: CharacterBody2D
@export var area: Node2D

func _process(delta: float) -> void:
	if player != null:
		global_position = player.global_position
		if Input.is_action_pressed("aim_up"):
			global_position = global_position + Vector2(0, -64)
		if Input.is_action_pressed("aim_down"):
			global_position = global_position + Vector2(0, 64)
