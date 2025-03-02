extends CharacterBody2D

# Enemy movement variables.
@export var gravity = 600
@export var speed: int = 50
@export var acceleration: float = 600
@export var chase_speed: int = 80  # Speed when chasing

# Enemy health and damage variables.
@export var health_amount: int = 3
@export var damage_amount: int = 1

# Direction and movement state.
var direction: Vector2 = Vector2.LEFT
var can_walk: bool = true

# Patrol system.
var no_of_points: int = 2
var point_positions: Array[Vector2] = []
var current_point_position: int = 0

# Chase variables.
var chasing: bool = false
var player_ref: Node2D = null

# Node references.
@onready var sprite = $Sprite
@onready var anim = $Animation
@onready var patrol_timer = $PatrolTimer
@onready var chase_timer = $ChaseTimer  # Timer for stopping chase
@onready var detection_area = $DetectionArea  # Reference to the Area2D

# Preloads the entity death effect.
var entity_death = preload("res://scenes/effects/entity_death.tscn")

# State machine.
enum States {idle, walk, chase, hurt, death}
var current_state: States = States.idle

func _ready() -> void:
	generate_patrol_points()

# Generates patrol points at fixed positions relative to the spawn position.
func generate_patrol_points() -> void:
	point_positions.clear()
	var spawn_position = global_position
	point_positions.append(spawn_position + Vector2(64, 0)) # First patrol point.
	point_positions.append(spawn_position + Vector2(-64, 0)) # Second patrol point.
	no_of_points = point_positions.size()
	current_point_position = 0  # Reset patrol index

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	
	if can_walk and current_state != States.death:
		if chasing and player_ref:
			roach_chase(delta) # Chase player.
		else:
			roach_patrol(delta) # Patrol normally.
	
	move_and_slide()
	animate_roach()

# Applies gravity if the enemy is airborne.
func apply_gravity(delta: float):
	if !is_on_floor() and current_state != States.death:
		velocity.y += gravity * delta

# Patrol logic, moves between dynamically generated patrol points.
func roach_patrol(delta: float):
	if point_positions.is_empty() and current_state != States.idle:
		return
	
	var target_point = point_positions[current_point_position]
	direction = (target_point - global_position).normalized()
	
	# Flip sprite based on movement direction.
	sprite.flip_h = direction.x < 0
	detection_area.position.x = -24 if sprite.flip_h else 24
	
	# Move towards the patrol point.
	velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)
	current_state = States.walk
	
	# Check if the enemy is close enough to the target point.
	if global_position.distance_to(target_point) < 2:
		global_position = target_point
		can_walk = false
		velocity.x = 0
		current_state = States.idle
		patrol_timer.stop()
		patrol_timer.start()

# Handles enemy chasing the player.
func roach_chase(delta: float):
	if not player_ref or current_state == States.death:
		return
	
	direction = (player_ref.global_position - global_position).normalized()
	
	# Flip sprite based on movement direction.
	sprite.flip_h = direction.x < 0
	detection_area.position.x = -24 if sprite.flip_h else 24
	
	# Move towards the player.
	velocity.x = move_toward(velocity.x, direction.x * chase_speed, acceleration * delta)
	current_state = States.chase

# Resumes movement after waiting at a patrol point.
func _on_patrol_timer_timeout() -> void:
	if !can_walk and not chasing:
		can_walk = true
		current_point_position = (current_point_position + 1) % no_of_points

# Handles player entering the detection area.
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):  # Ensure it's the player.
		chasing = true
		player_ref = body
		can_walk = true  # Allow movement immediately.
		chase_timer.stop()  # Reset the cooldown timer.

# Handles player exiting the detection area.
func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player_ref:
		chase_timer.start()  # Start the 1-second chase timer.

# Stops chase after the cooldown period.
func _on_chase_timer_timeout() -> void:
	chasing = false
	player_ref = null
	
	generate_patrol_points()  # Generate new patrol points at current position.
	can_walk = true  # Resume patrolling.

# Handles enemy taking damage when hit by a bullet.
func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.get_parent().has_method("get_damage_amount"):
		var node = area.get_parent() as Node
		health_amount -= node.damage_amount # Reduce health based on bullet damage.

		current_state = States.hurt
		can_walk = false # Stop movement.
		velocity.x = 0
		velocity.y = 0
		await get_tree().create_timer(0.2).timeout # Brief stun duration.
		
		if health_amount <= 0:
			current_state = States.death
			await anim.animation_finished # Wait for death animation to finish.
			
			# Spawn the death effect at the enemy's position.
			var entity_death_instance = entity_death.instantiate() as Node2D
			entity_death_instance.global_position = global_position + sprite.position
			get_parent().add_child(entity_death_instance)
			
			queue_free() # Remove the enemy from the scene.
		else:
			can_walk = true # Resume movement if still alive.

# Updates animation based on current state.
func animate_roach():
	match current_state:
		States.idle:
			if anim.current_animation != "idle":
				anim.play("idle")
		States.walk:
			if anim.current_animation != "walk":
				anim.play("walk")
		States.chase:
			if anim.current_animation != "walk":
				anim.play("walk")
		States.hurt:
			if anim.current_animation != "hurt":
				anim.play("hurt")
		States.death:
			if anim.current_animation != "death":
				anim.play("death", -1, 1, false) # Play death animation once without looping.
