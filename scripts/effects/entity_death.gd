extends AnimatedSprite2D

# Node references.
@onready var light: PointLight2D = $Light

# Sound references.
@onready var snd_entity_death: AudioStreamPlayer2D = $Sounds/EntityDeath

func _process(_delta: float) -> void:
	animate_light()

func _ready() -> void:
	snd_entity_death.play()
	await snd_entity_death.finished
	queue_free()

# Animates light according to the frame.
func animate_light() -> void:
	var current_frame = frame
	match animation:
		"death":
			match current_frame:
				0:
					light.energy = 1.0
				1:
					light.energy = 0.75
				2:
					light.energy = 0.5
				3:
					light.energy = 0.25
				4:
					light.energy = 0.0
