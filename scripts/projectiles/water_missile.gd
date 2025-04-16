extends AnimatedSprite2D

# Missile properties.
@export var speed: int = 300
@export var direction: Vector2
@export var damage_amount: int = 3
var shooter: Node2D # Reference to the shooter (e.g., Player).

# Preloads the impact effect.
var water_explosion = preload("res://scenes/effects/water_explosion.tscn")

func _ready() -> void:
	# Rotate the missile to match its direction.
	rotation = direction.angle()
	add_to_group("destroying")

func _physics_process(delta: float) -> void:
	move_missile(delta)

func move_missile(delta: float) -> void:
	position += direction * speed * delta

func _on_timer_timeout() -> void:
	explode()
	queue_free()

func get_damage_amount() -> int:
	return damage_amount

func _on_hitbox_area_entered(_area: Area2D) -> void:
	explode()

func _on_hitbox_body_entered(_body: Node2D) -> void:
	explode()

func explode() -> void:
	var explosion_instance = water_explosion.instantiate() as Node2D
	explosion_instance.global_position = global_position
	get_parent().add_child(explosion_instance)
	queue_free()
