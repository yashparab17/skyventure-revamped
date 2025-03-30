extends CharacterBody2D

# Node references.
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite

# Fireball properties.
@export var speed: int = 150
@export var direction: Vector2
@export var damage_amount: int = 2
@export var gravity: float = 600
@export var bounce_velocity: float = -100
var shooter: Node2D # Reference to the shooter (e.g., Player).

# Preloads the fireball impact effect.
var fireball_impact = preload("res://scenes/effects/fireball_impact.tscn")

func _ready() -> void:
	# Rotate the fireball to match its direction.
	animated_sprite.rotation = direction.angle()
	velocity = direction * speed

func _physics_process(delta: float) -> void:
	move_fireball(delta)

# Moves the fireball in the set direction every frame, applying gravity.
func move_fireball(delta: float) -> void:
	velocity.y += gravity * delta
	var collision = move_and_collide(velocity * delta)
	if collision:
		handle_collision(collision.get_collider(), collision.get_normal())

# Deletes the fireball when the timer runs out.
func _on_timer_timeout() -> void:
	spawn_impact_effect()
	queue_free()

# Returns the damage amount of the fireball.
func get_damage_amount() -> int:
	return damage_amount

# Handles collision when the fireball hits an area or body.
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		handle_collision(area, Vector2.UP) # Default to floor collision for areas.

# Handles the fireball impact effect and deletes the fireball.
func handle_collision(collider: Object, normal: Vector2) -> void:
	if collider.is_in_group("enemy"):
		# Collision with an enemy.
		spawn_impact_effect()
		queue_free()
	elif normal == Vector2.UP or normal == Vector2.DOWN:
		# Collision with floor or ceiling.
		bounce()
	elif normal == Vector2.LEFT or normal == Vector2.RIGHT:
		# Collision with wall.
		reverse_direction()
	else:
		# Handle other collisions (e.g., diagonal).
		spawn_impact_effect()
		queue_free()

# Bounces the fireball when it hits the ground.
func bounce() -> void:
	velocity.y = bounce_velocity

# Reverses the fireball's horizontal direction when it hits a wall.
func reverse_direction() -> void:
	velocity.x = - velocity.x

# Spawns the fireball impact effect at the fireball's position.
func spawn_impact_effect() -> void:
	var fireball_impact_instance = fireball_impact.instantiate() as Node2D
	fireball_impact_instance.global_position = global_position
	get_parent().add_child(fireball_impact_instance)
