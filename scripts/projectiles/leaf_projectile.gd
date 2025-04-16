extends AnimatedSprite2D

# Bullet properties.
@export var speed: int = 400
@export var direction: Vector2
@export var damage_amount: int = 1
var shooter: Node2D # Reference to the shooter (e.g., Player).

# Preloads the impact effect.
var leaf_impact = preload("res://scenes/effects/leaf_impact.tscn")

func _ready() -> void:
	# Rotate the leaf to match its direction.
	rotation = direction.angle()
	add_to_group("destroying")

func _physics_process(delta: float) -> void:
	move_leaf(delta)

func move_leaf(delta: float) -> void:
	position += direction * speed * delta

func _on_timer_timeout() -> void:
	spawn_impact_effect()
	queue_free()

func get_damage_amount() -> int:
	return damage_amount

func _on_hitbox_area_entered(_area: Area2D) -> void:
	handle_collision()

func _on_hitbox_body_entered(_body: Node2D) -> void:
	handle_collision()

func handle_collision() -> void:
	spawn_impact_effect()
	queue_free()

func spawn_impact_effect() -> void:
	var leaf_impact_instance = leaf_impact.instantiate() as Node2D
	leaf_impact_instance.global_position = global_position
	get_parent().add_child(leaf_impact_instance)
