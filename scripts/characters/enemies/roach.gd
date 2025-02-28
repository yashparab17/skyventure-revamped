extends CharacterBody2D

# Enemy movement properties.
@export var gravity = 600
@export var speed: int = 60 # Slightly faster than normal patrol enemies.
@export var acceleration: float = 600

# Enemy health and damage properties.
@export var health_amount: int = 3
@export var damage_amount: int = 1

# Patrol system.
@export var patrol_points: Node # Parent node containing patrol points.
@export var wait_time: int = 3 # Time to wait at each patrol point.
var no_of_points: int = 0
var point_positions: Array[Vector2] = []
var current_point_position: int = 0

# Tracking the player.
var player: Node2D = null
var chasing: bool = false

# Direction and movement state.
var direction: Vector2 = Vector2.LEFT
var can_walk: bool = true

# Node references.
@onready var sprite = $Sprite
@onready var anim = $Animation
@onready var timer = $Timer

# Preloads the entity death effect.
var entity_death = preload("res://scenes/effects/entity_death.tscn")

# State machine.
enum States {idle, walk, chase, hurt, death}
var current_state: States = States.idle

func _ready() -> void:
	# Initialize patrol points.
	if patrol_points:
		no_of_points = patrol_points.get_child_count()
		for point in patrol_points.get_children():
			point_positions.append(point.global_position)
	else:
		print("No patrol points available.")
	
	timer.wait_time = wait_time # Set timer wait duration.

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	
	if can_walk and current_state != States.death:
		if chasing:
			chase_player(delta)
		else:
			roach_patrol(delta)
	
	move_and_slide()
	animate_roach()

# Applies gravity if the enemy is airborne.
func apply_gravity(delta: float):
	if !is_on_floor() and current_state != States.death:
		velocity.y += gravity * delta

# Patrol logic, moving between defined patrol points.
func roach_patrol(delta: float):
	if point_positions.is_empty():
		return
		
	var target_point = point_positions[current_point_position]
	direction = (target_point - global_position).normalized()
	sprite.flip_h = direction.x < 0
	
	# Move towards the patrol point.
	velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)
	current_state = States.walk
	
	# Stop moving when close enough to the target.
	if global_position.distance_to(target_point) < 5:
		if chasing:
			current_state = States.chase
		else:
			stop_and_wait()

# Chase logic, follows the player when detected.
func chase_player(delta: float):
	if not player:
		return
	
	direction = (player.global_position - global_position).normalized()
	sprite.flip_h = direction.x < 0
	velocity.x = move_toward(velocity.x, direction.x * (speed + 30), acceleration * delta) # Slightly faster when chasing.
	current_state = States.chase

# Stops the enemy at a patrol point and waits.
func stop_and_wait():
	can_walk = false
	velocity.x = 0
	current_state = States.idle
	timer.start()

# Resumes movement after waiting at a patrol point.
func _on_timer_timeout() -> void:
	if chasing:
		current_state = States.chase
	else:
		can_walk = true
		current_point_position = (current_point_position + 1) % no_of_points

# Handles enemy taking damage when hit by a bullet.
func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.get_parent().has_method("get_damage_amount"):
		var node = area.get_parent() as Node
		health_amount -= node.damage_amount # Reduce health based on bullet damage.

		current_state = States.hurt
		can_walk = false # Stop movement.
		velocity.x = 0
		await get_tree().create_timer(0.2).timeout # Brief stun duration.
		
		if health_amount <= 0:
			die()
		else:
			can_walk = true # Resume movement if still alive.

# Handles the enemy's death.
func die():
	current_state = States.death
	velocity.x = 0
	velocity.y = 0
	await anim.animation_finished
	
	# Spawn the death effect at the enemy's position.
	var entity_death_instance = entity_death.instantiate() as Node2D
	entity_death_instance.global_position = global_position + sprite.position
	get_parent().add_child(entity_death_instance)
	
	queue_free()

func _on_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		chasing = true
		print("Detection area entered.")

		if !can_walk:
			timer.stop()
			can_walk = true
			current_state = States.chase

func _on_detection_body_exited(body: Node2D) -> void:
	if body == player:
		await get_tree().create_timer(1.0).timeout
		player = null
		chasing = false
		current_state = States.idle
		
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
				anim.play("death", -1, 1, false) # Plays death animation once without looping.
