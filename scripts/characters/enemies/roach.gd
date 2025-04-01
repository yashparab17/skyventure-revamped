extends CharacterBody2D

# Preload scenes for effects and pickups.
var entity_death = preload("res://scenes/effects/entity_death.tscn")
var health_pickup = preload("res://scenes/items/pickups/health_pickup.tscn")

# Enemy movement properties.
@export var gravity: float = 600
@export var speed: int = 50
@export var acceleration: float = 600
@export var chase_speed: int = 80 # Speed when chasing.

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

# Chase system variables.
var chasing: bool = false
var player_ref: Node2D = null

# Movement state.
var direction: Vector2
var can_walk: bool = true

# Node references.
@onready var sprite = $Sprite
@onready var anim = $Animation
@onready var patrol_timer = $PatrolTimer
@onready var chase_timer = $ChaseTimer
@onready var detection_area = $DetectionArea

# Sound references.
@onready var snd_alert = $Sounds/Alert
@onready var snd_hurt = $Sounds/Hurt
@onready var snd_death = $Sounds/Death

# State machine.
enum States {IDLE, WALK, ALERT, CHASE, ATTACK, HURT, DEATH}
var current_state: States = States.IDLE

# Enemy score.
@export var score: int = 100

func _ready() -> void:
	generate_patrol_points()

# Generates patrol points relative to the spawn position.
func generate_patrol_points() -> void:
	point_positions.clear()
	var spawn_position = global_position
	point_positions.append(spawn_position + first_patrol_point)
	point_positions.append(spawn_position + second_patrol_point)
	no_of_points = point_positions.size()
	current_point_position = 0 # Reset patrol index.

func _physics_process(delta: float) -> void:
	apply_gravity(delta)

	if can_walk and current_state != States.DEATH:
		if chasing and player_ref:
			chase_player(delta) # Chase the player.
		else:
			patrol(delta) # Patrol normally.

	move_and_slide()
	update_animation()

# Applies gravity if the enemy is airborne.
func apply_gravity(delta: float) -> void:
	if !is_on_floor() and current_state != States.DEATH:
		velocity.y += gravity * delta

# Patrol logic: Moves between dynamically generated patrol points.
func patrol(delta: float) -> void:
	if point_positions.is_empty() and current_state != States.IDLE:
		return

	var target_point = point_positions[current_point_position]
	direction = (target_point - global_position).normalized()

	if is_on_wall():
		# Reverse direction if colliding with a wall.
		current_point_position = (current_point_position + 1) % no_of_points
		return

	# Flip sprite based on movement direction.
	flip_direction(direction.x)

	# Move towards the patrol point.
	velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)
	current_state = States.WALK

	# Check if the enemy is close enough to the target point.
	if global_position.distance_to(target_point) < 2:
		global_position = target_point
		can_walk = false
		velocity.x = 0
		current_state = States.IDLE
		patrol_timer.stop()
		patrol_timer.start()

# Flips the sprite and detection area based on direction.
func flip_direction(dir_x: float) -> void:
	if dir_x != 0:
		sprite.flip_h = dir_x < 0
		detection_area.position.x = -24 if sprite.flip_h else 24

# Alert jump before chasing.
func alert() -> void:
	if is_on_floor():
		direction = (player_ref.global_position - global_position).normalized()
		flip_direction(direction.x)
		velocity.y = -150 # Jump force.
		current_state = States.ALERT
		snd_alert.play()
		await anim.animation_finished # Wait before starting chase.

		# Start chasing.
		current_state = States.CHASE
		can_walk = true # Allow movement again.

# Handles chasing the player.
func chase_player(delta: float) -> void:
	if not player_ref or current_state == States.DEATH:
		return

	direction = (player_ref.global_position - global_position).normalized()
	flip_direction(direction.x)
	velocity.x = move_toward(velocity.x, direction.x * chase_speed, acceleration * delta)
	current_state = States.CHASE

# Resumes movement after waiting at a patrol point.
func _on_patrol_timer_timeout() -> void:
	if !can_walk and not chasing:
		can_walk = true
		current_point_position = (current_point_position + 1) % no_of_points

# Handles player entering the detection area.
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and current_state not in [States.CHASE, States.ALERT]:
		player_ref = body
		chasing = true
		can_walk = false # Stop movement.
		velocity.x = 0
		alert()
		chase_timer.stop() # Stop the timer when the player is detected (reset it).

# Handles player exiting the detection area.
func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player_ref:
		chase_timer.start() # Start the 2-second chase timer.

# Handles player entering the attack area.
func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		current_state = States.ATTACK
		can_walk = false
		velocity = Vector2.ZERO
		await anim.animation_finished # Wait for animation to finish.
		can_walk = true # Resume movement after attack.

# Stops chase after the cooldown period.
func _on_chase_timer_timeout() -> void:
	# Only stop chasing if the player is still outside the detection area.
	if not detection_area.has_overlapping_bodies() or player_ref == null:
		chasing = false
		player_ref = null
		generate_patrol_points() # Generate new patrol points at current position.
		can_walk = true # Resume patrolling.

# Handles enemy taking damage when hit by a bullet.
func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.get_parent().has_method("get_damage_amount"):
		var bullet = area.get_parent() as Node
		var bullet_damage = bullet.damage_amount
		var bullet_shooter = bullet.shooter

		health_amount -= bullet_damage # Reduce health based on bullet damage.
		flip_direction(-bullet.global_position.direction_to(global_position).x)

		current_state = States.HURT
		snd_hurt.play()
		can_walk = false # Stop movement.
		velocity = Vector2.ZERO
		await get_tree().create_timer(0.2).timeout # Brief stun duration.

		if health_amount <= 0:
			die()
		else:
			# Aggravate the roach and start chasing.
			player_ref = bullet_shooter
			chasing = true
			can_walk = true
			current_state = States.CHASE

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
		States.IDLE:
			if anim.current_animation != "idle":
				anim.play("idle")
		States.WALK:
			if anim.current_animation != "walk":
				anim.play("walk")
		States.ALERT:
			if anim.current_animation != "alert":
				anim.play("alert")
		States.CHASE:
			if anim.current_animation != "chase":
				anim.play("chase")
		States.ATTACK:
			if anim.current_animation != "attack":
				anim.play("attack")
		States.HURT:
			if anim.current_animation != "hurt":
				anim.play("hurt")
		States.DEATH:
			if anim.current_animation != "death":
				anim.play("death", -1, 1, false) # Play death animation once without looping.
