extends StaticBody2D

var block_destroy = preload("res://scenes/effects/block_destroy.tscn")

func _on_detection_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("destroying"):
		area.handle_collision()
		handle_destroy()

func handle_destroy() -> void:
	spawn_destroy_effect()
	queue_free()

func spawn_destroy_effect() -> void:
	var block_destroy_instance = block_destroy.instantiate() as Node2D
	block_destroy_instance.global_position = global_position
	get_parent().add_child(block_destroy_instance)
