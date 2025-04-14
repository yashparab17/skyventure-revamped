extends AnimatedSprite2D

signal teleport_finished

# Node references.
@onready var light: PointLight2D = $Light

# Sound references.
@onready var snd_teleport: AudioStreamPlayer2D = $Sounds/Teleport

func _process(_delta: float) -> void:
	animate_light()

func _ready() -> void:
	snd_teleport.play()
	await snd_teleport.finished
	emit_signal("teleport_finished")
	queue_free()

# Animates light according to the frame.
func animate_light() -> void:
	var current_frame = frame
	match animation:
		"teleport":
			match current_frame:
				0:
					light.energy = 0.75
				1:
					light.energy = 1.0
				2:
					light.energy = 0.25
				3:
					light.energy = 0.75
				4:
					light.energy = 1.0
				5:
					light.energy = 0.25
				6:
					light.energy = 0.75
				7:
					light.energy = 1.0
				8:
					light.energy = 0.25
				9:
					light.energy = 0.75
				10:
					light.energy = 1.0
				11:
					light.energy = 0.25
				12:
					light.energy = 0.0
