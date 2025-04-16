extends CharacterBody2D

################################################################################
# PRELOADS
################################################################################

var entity_death = preload("res://scenes/effects/entity_death.tscn")
var health_pickup = preload("res://scenes/items/pickups/health_pickup.tscn")

################################################################################
# EXPORT PROPERTIES
################################################################################

@export var gravity: float = 500
@export var jump_force: float = -200
@export var jump_horizontal_speed: int = 30
@export var score: int = 50
@export var jump_cooldown: float = 0.25
@export var damage_amount: int = 1

################################################################################
# JUMP SYSTEM
################################################################################

var jump_direction: Vector2 = Vector2.ZERO
var player_ref: Node2D = null
var ready_to_jump: bool = true
var just_jumped = false
var jump_buffer_timer := 0.15
var jump_buffer = 0.0

################################################################################
# NODE REFERENCES
################################################################################

@onready var collision: CollisionShape2D = $Collision
@onready var hurtbox_collision: CollisionShape2D = $Hurtbox/HurtboxCollision
@onready var sprite: Sprite2D = $Sprite
@onready var anim: AnimationPlayer = $Animation
@onready var initial_detection: Area2D = $InitialDetectionArea
@onready var detection_area: Area2D = $DetectionArea
@onready var land_timer: Timer = $LandTimer

# Sound references.
@onready var snd_jump: AudioStreamPlayer2D = $Sounds/Jump
@onready var snd_death: AudioStreamPlayer2D = $Sounds/Death

################################################################################
# STATE MACHINE
################################################################################

enum States {ASLEEP, AWAKE, JUMP, LAND, DEATH}
var current_state: States = States.ASLEEP

################################################################################
# CORE FUNCTIONS
################################################################################

# Function that activates when the scene is ready.
func _ready() -> void:
	if SpawnManager.player:
		player_ref = SpawnManager.player
		update_facing_direction()
	else:
		# Wait for the signal when the player is spawned.
		SpawnManager.player_spawned.connect(_on_player_spawned)

# Finds the player.
func _on_player_spawned() -> void:
	player_ref = SpawnManager.player
	update_facing_direction()

# Runs every physics frame.
func _physics_process(delta: float) -> void:
	apply_gravity(delta)

	# If the player has exited the detection area, reset horizontal velocity.
	if current_state == States.JUMP:
		if !is_player_in_detection_area():
			velocity.x = 0

	# Jumping function.
	if current_state == States.JUMP:
		velocity.x = jump_direction.x * jump_horizontal_speed
	elif current_state in [States.AWAKE, States.LAND]:
		velocity.x = 0

	move_and_slide()
	update_animation()

	# If the jump buffer is active, it can jump again.
	if just_jumped:
		jump_buffer -= delta
		if jump_buffer <= 0:
			just_jumped = false

	# If the enemy is on the floor and in the jump state, it will land.
	if is_on_floor() and current_state == States.JUMP and !just_jumped:
		velocity.x = 0
		land()

	# If the enemy is in the awake state, it will check if the player is in the detection area.
	if current_state == States.AWAKE and ready_to_jump and is_on_floor() and is_player_in_detection_area():
		jump_towards_player()

################################################################################
# MOVEMENT FUNCTIONS
################################################################################

# Applies gravity to the enemy.
func apply_gravity(delta: float) -> void:
	if !is_on_floor() and current_state != States.DEATH:
		velocity.y += gravity * delta

# Flips the sprite based on the player's position.
func update_facing_direction() -> void:
	if player_ref:
		sprite.flip_h = player_ref.global_position.x < global_position.x

# Jumps towards the player.
func jump_towards_player() -> void:
	if player_ref and current_state != States.DEATH and ready_to_jump:
		# If the player is in the detection area, it will jump towards the player.
		jump_direction = (player_ref.global_position - global_position).normalized()
		velocity.y = jump_force

		# Play the jump sound effect.
		SoundManager.play_sound_2d(snd_jump.stream, global_position, 8)

		# Set the state to JUMP.
		current_state = States.JUMP
		ready_to_jump = false

		# Update facing direction.
		update_facing_direction()

		# Set the jump buffer.
		jump_buffer = jump_buffer_timer
		just_jumped = true

# Lands after jumping.
func land() -> void:
	velocity = Vector2.ZERO
	current_state = States.LAND
	land_timer.start(jump_cooldown)

################################################################################
# STATE TRANSITIONS
################################################################################

# Wakes the enemy up.
func wake_up() -> void:
	if current_state == States.ASLEEP:
		current_state = States.AWAKE
		ready_to_jump = true
		update_facing_direction()

################################################################################
# DETECTION FUNCTIONS
################################################################################

# Checks if the player is in the detection area.
func is_player_in_detection_area() -> bool:
	for body in detection_area.get_overlapping_bodies():
		if body.is_in_group("player"):
			return true
	return false

# Checks if the player is in the initial detection area.
func _on_initial_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		wake_up()

# Checks if the player has exited the initial detection area.
func _on_initial_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		try_go_to_sleep()

# Tries to put the enemy to sleep.
func try_go_to_sleep() -> void:
	if !is_player_in_detection_area() and current_state != States.DEATH:
		current_state = States.ASLEEP
		land_timer.stop()
		ready_to_jump = false

################################################################################
# TIMER FUNCTIONS
################################################################################

# Timer to check if the enemy has landed.
func _on_land_timer_timeout() -> void:
	# Check if the enemy is on the floor.
	if is_on_floor():
		ready_to_jump = true
		current_state = States.AWAKE
		update_facing_direction()
		
		# Only jump if it landed and player is nearby
		if is_player_in_detection_area():
			jump_towards_player()
	else:
		# Safety: wait a bit and check again.
		land_timer.start(0.1)

################################################################################
# COMBAT FUNCTIONS
################################################################################

# Handles the enemy's collision with the player and pitfalls.
func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("pitfall") or area.get_parent().has_method("handle_collision") or area.get_parent().has_method("explode"):
		die()

# Handles the enemy's collision with the player.
func die() -> void:
	collision.call_deferred("set_disabled", true)
	hurtbox_collision.call_deferred("set_disabled", true)
	current_state = States.DEATH
	velocity = Vector2.ZERO
	
	var death_sound_player = SoundManager.play_sound_2d(snd_death.stream, global_position)
	await death_sound_player.finished
	set_process(false)
	set_physics_process(false)

	var entity_death_instance = entity_death.instantiate() as Node2D
	entity_death_instance.global_position = global_position + sprite.position
	get_parent().add_child(entity_death_instance)

	if randf() < 0.25:
		var health_pickup_instance = health_pickup.instantiate() as Node2D
		health_pickup_instance.global_position = global_position + sprite.position
		get_parent().add_child(health_pickup_instance)

	GameState.increment_score(score)
	queue_free()

################################################################################
# ANIMATION FUNCTIONS
################################################################################

func update_animation() -> void:
	match current_state:
		States.ASLEEP:
			if anim.current_animation != "asleep":
				anim.play("asleep")
		States.AWAKE:
			if anim.current_animation != "awake":
				anim.play("awake")
		States.JUMP:
			if anim.current_animation != "jump":
				anim.play("jump")
		States.LAND:
			if anim.current_animation != "land":
				anim.play("land")
		States.DEATH:
			if anim.current_animation != "death":
				anim.play("death")
