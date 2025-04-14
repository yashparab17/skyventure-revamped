extends AnimatedSprite2D

# Bullet properties.
@export var speed: int = 500
@export var direction: Vector2
@export var damage_amount: int = 1
var shooter: Node2D # Reference to the shooter (e.g., Player).

# Preloads the bullet impact effect.
var star_bullet_impact = preload("res://scenes/effects/star_bullet_impact.tscn")

func _ready() -> void:
	# Rotate the bullet to match its direction.
	rotation = direction.angle()
	add_to_group("destroying")

func _physics_process(delta: float) -> void:
	move_bullet(delta)

# Moves the bullet in the set direction every frame.
func move_bullet(delta: float) -> void:
	position += direction * speed * delta

# Deletes the bullet when the timer runs out.
func _on_timer_timeout() -> void:
	spawn_impact_effect()
	queue_free()

# Returns the damage amount of the bullet.
func get_damage_amount() -> int:
	return damage_amount

# Handles collision when the bullet hits an area or body.
func _on_hitbox_area_entered(area: Area2D) -> void:
	handle_collision()

func _on_hitbox_body_entered(body: Node2D) -> void:
	handle_collision()

# Handles the bullet impact effect and deletes the bullet.
func handle_collision() -> void:
	spawn_impact_effect()
	queue_free()

# Spawns the bullet impact effect at the bullet's position.
func spawn_impact_effect() -> void:
	var star_bullet_impact_instance = star_bullet_impact.instantiate() as Node2D
	star_bullet_impact_instance.global_position = global_position
	get_parent().add_child(star_bullet_impact_instance)
