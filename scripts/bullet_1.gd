extends AnimatedSprite2D

# Bullet properties.
@export var speed: int = 500
@export var direction: int  # 1 for right, -1 for left.

func _physics_process(delta: float) -> void:
	# Move the bullet in the set direction.
	move_local_x(direction * speed * delta)

# Deletes the bullet when the timer runs out.
func _on_timer_timeout() -> void:
	queue_free()
