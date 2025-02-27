extends Area2D

@export var gun_scene: PackedScene = preload("res://scenes/items/gun_1.tscn")

# Checks if player has entered the body. If they have, then collect the gun.
func _on_body_entered(body):
	if body is CharacterBody2D:
		if body.has_method("collect_gun"):
			body.collect_gun()
			queue_free()
