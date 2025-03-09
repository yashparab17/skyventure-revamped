extends AnimatedSprite2D

@onready var snd_entity_death = $Sounds/EntityDeath

func _ready() -> void:
	snd_entity_death.play()
	await snd_entity_death.finished
	queue_free()
