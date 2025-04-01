extends CharacterBody2D

# Preload scenes for effects and pickups.
var entity_death = preload("res://scenes/effects/entity_death.tscn")
var health_pickup = preload("res://scenes/items/pickups/health_pickup.tscn")

# Enemy movement properties.
@export var speed: int = 50
@export var acceleration: float = 600
@export var friction: float = 600 # Friction for smooth deceleration.

# Enemy health and damage properties.
@export var health_amount: int = 3
@export var damage_amount: int = 1

# Patrol system variables.
var no_of_points: int = 2
var point_positions: Array[Vector2] = []
var current_point_position: int = 0

# Export patrol variables.
@export var first_patrol_point: Vector2
@export var second_patrol_point: Vector2

# Movement state.
var direction: Vector2
var can_move: bool = true

# Player reference.
var player_ref: Node2D = null

# Node references.
@onready var sprite = $Sprite
@onready var anim = $Animation

# Sound references.
@onready var snd_hurt = $Sounds/Hurt
@onready var snd_death = $Sounds/Death

# State machine.
enum States {FLY, HURT, DEATH}
var current_state: States = States.FLY

# Enemy score.
@export var score: int = 100

func _ready() -> void:
	generate_patrol_points()
	# Find the player node in the scene.
	player_ref = get_tree().get_first_node_in_group("player")

# Generates patrol points relative to the spawn position.
func generate_patrol_points() -> void:
	point_positions.clear()
	var spawn_position = global_position
	point_positions.append(spawn_position + first_patrol_point)
	point_positions.append(spawn_position + second_patrol_point)
	no_of_points = point_positions.size()
	current_point_position = 0 # Reset patrol index.

func _physics_process(delta: float) -> void:
	if can_move and current_state != States.DEATH:
		patrol(delta) # Patrol between points.

	# Constantly face the player.
	if player_ref:
		face_player()

	move_and_slide()
	update_animation()

# Patrol logic: Moves between dynamically generated patrol points.
func patrol(delta: float) -> void:
	if point_positions.is_empty():
		return

	var target_point = point_positions[current_point_position]
	direction = (target_point - global_position).normalized()

	# Apply acceleration towards the target point.
	velocity.y = move_toward(velocity.y, direction.y * speed, acceleration * delta)

	# Apply friction when close to the target point.
	if global_position.distance_to(target_point) < 10:
		velocity.y = move_toward(velocity.y, 0, friction * delta)

	# Check if the enemy is close enough to the target point.
	if global_position.distance_to(target_point) < 2:
		global_position = target_point
		can_move = false
		velocity = Vector2.ZERO # Ensure velocity is fully reset.
		current_state = States.FLY
		await get_tree().create_timer(1.0).timeout # Wait for 1 second before moving to the next point.
		current_point_position = (current_point_position + 1) % no_of_points
		can_move = true

# Makes the roach face the player.
func face_player() -> void:
	if player_ref:
		var player_direction = (player_ref.global_position - global_position).normalized()
		sprite.flip_h = player_direction.x < 0 # Flip sprite based on player's position.

# Handles enemy taking damage when hit by a bullet.
func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.get_parent().has_method("get_damage_amount"):
		var bullet = area.get_parent() as Node
		var bullet_damage = bullet.damage_amount

		health_amount -= bullet_damage # Reduce health based on bullet damage.
		current_state = States.HURT
		snd_hurt.play()
		can_move = false # Stop movement.
		velocity = Vector2.ZERO
		await get_tree().create_timer(0.2).timeout # Brief stun duration.

		if health_amount <= 0:
			die()
		else:
			can_move = true
			current_state = States.FLY

# Handles enemy death.
func die() -> void:
	current_state = States.DEATH
	snd_death.play()
	velocity = Vector2.ZERO
	await anim.animation_finished # Wait for death animation to finish.

	# Spawn death effect.
	var entity_death_instance = entity_death.instantiate() as Node2D
	entity_death_instance.global_position = global_position + sprite.position
	get_parent().add_child(entity_death_instance)

	# 75% chance to drop a health pickup.
	if randf() < 0.75:
		var health_pickup_instance = health_pickup.instantiate() as Node2D
		health_pickup_instance.global_position = global_position + sprite.position
		get_parent().add_child(health_pickup_instance)

	ScoreManager.increment_score(score)
	queue_free() # Remove the enemy from the scene.

# Updates animation based on current state.
func update_animation() -> void:
	match current_state:
		States.FLY:
			if anim.current_animation != "fly":
				anim.play("fly")
		States.HURT:
			if anim.current_animation != "hurt":
				anim.play("hurt")
		States.DEATH:
			if anim.current_animation != "death":
				anim.play("death", -1, 1, false) # Play death animation once without looping.
