extends StaticBody2D

# Direction of the spike.
@export_enum("Up", "Right", "Down", "Left") var facing_direction: String = "Up"

func _ready() -> void:
	match facing_direction:
		"Up":
			rotation_degrees = 0
		"Right":
			rotation_degrees = 90
		"Down":
			rotation_degrees = 180
		"Left":
			rotation_degrees = 270

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(1, global_position.x)
