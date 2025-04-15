extends AnimatedSprite2D

# Node references.
@onready var light: PointLight2D = $Light

# Sound references.
@onready var snd_block_destroy: AudioStreamPlayer2D = $Sounds/BlockDestroySound

func _process(_delta: float) -> void:
	animate_light()

func _ready() -> void:
	var block_destroy_player = SoundManager.play_sound_2d(snd_block_destroy.stream, global_position)
	await block_destroy_player.finished
	queue_free()

# Animates light according to the frame.
func animate_light() -> void:
	var current_frame = frame
	match animation:
		"destroy":
			match current_frame:
				0:
					light.energy = 1.0
				1:
					light.energy = 0.875
				2:
					light.energy = 0.75
				3:
					light.energy = 0.625
				4:
					light.energy = 0.5
				5:
					light.energy = 0.375
				6:
					light.energy = 0.25
				7:
					light.energy = 0.125
