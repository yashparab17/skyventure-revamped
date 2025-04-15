extends AnimatedSprite2D

@export var health_amount: int = 1
@onready var snd_health_pickup: AudioStreamPlayer2D = $Sounds/Pickup

# Handles collision when the health pickup hits a body.
func _on_pickup_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if GameState.current_health == GameState.max_health:
			pass
		else:
			GameState.increase_health(health_amount)
			visible = false
			SoundManager.play_sound_2d(snd_health_pickup.stream, global_position)
			await snd_health_pickup.finished
			queue_free()
