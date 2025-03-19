extends AnimatedSprite2D

@export var health_amount: int = 1
@onready var snd_health_pickup = $Sounds/Pickup

# Handles collision when the health pickup hits a body.
func _on_pickup_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if HealthManager.current_health == 3:
			pass
		else:
			HealthManager.increase_health(health_amount)
			visible = false
			snd_health_pickup.play()
			await snd_health_pickup.finished
			queue_free()
