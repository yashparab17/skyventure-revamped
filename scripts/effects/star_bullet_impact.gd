extends AnimatedSprite2D

# Node references.
@onready var light: PointLight2D = $Light

func _process(delta):
	# Animates light according to the frame.
	var current_frame = frame
	match animation:
		"impact":
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

func _on_timer_timeout() -> void:
	queue_free()
