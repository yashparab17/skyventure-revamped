extends AnimatedSprite2D

func _process(delta: float) -> void:
	await animation_finished
	queue_free()
