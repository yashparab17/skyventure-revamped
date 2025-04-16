extends CharacterBody2D

################################################################################
# PRELOADS
################################################################################

# Preload scenes for effects.
var entity_death = preload("res://scenes/effects/entity_death.tscn")
var teleport = preload("res://scenes/effects/teleport.tscn")

################################################################################
# PROPERTIES
################################################################################

# Player movement properties.
var gravity: float = 500
var speed: int = 110
var jump_force: int = -225
var acceleration: float = 600
var friction: float = 800

# Player hurt properties.
var hurt_knockback: Vector2 = Vector2(200, -200)
var hurt_duration: float = 0.5

# Last safe position.
var last_safe_position: Vector2
var safe_ground_timer := 0.0
var has_saved_safe_pos := false

# Coyote time
var coyote_time: float = 0.1
var coyote_timer: float = 0.0

# Checks if player can move.
var can_move: bool = true

# Booster properties.
var is_boosting: bool = false
var boost_timer: float = 0.0
var boost_duration: float = 0.35
var boost_speed: float = 300

################################################################################
# NODE REFERENCES
################################################################################

@onready var collision: CollisionShape2D = $Collision
@onready var hurtbox_collision: CollisionShape2D = $Hurtbox/HurtboxCollision
@onready var sprite: Sprite2D = $Sprite
@onready var anim: AnimationPlayer = $Animation
@onready var aim_node: Node2D = $AimNode
@onready var invuln_timer: Timer = $InvulnerabilityTimer
@onready var blink_timer: Timer = $BlinkTimer

# Sound references.
@onready var snd_walk: AudioStreamPlayer = $Sounds/Walk
@onready var snd_jump: AudioStreamPlayer = $Sounds/Jump
@onready var snd_bonk: AudioStreamPlayer = $Sounds/Bonk
@onready var snd_hurt: AudioStreamPlayer = $Sounds/Hurt
@onready var snd_death: AudioStreamPlayer = $Sounds/Death

# Weapon sound references.
@onready var snd_switch_weapon: AudioStreamPlayer = $Sounds/SwitchWeapon
@onready var snd_proj_star_bullet: AudioStreamPlayer = $Sounds/ProjectileStarBullet
@onready var snd_proj_fireball: AudioStreamPlayer = $Sounds/ProjectileFireball
@onready var snd_proj_leaf: AudioStreamPlayer = $Sounds/ProjectileLeaf
@onready var snd_proj_water_missile: AudioStreamPlayer = $Sounds/ProjectileWaterMissile

################################################################################
# STATE MANAGEMENT
################################################################################

# State machine
enum States {IDLE, WALK, JUMP, FALL, IDLE_SHOOT, WALK_SHOOT, JUMP_SHOOT, FALL_SHOOT, INTERACT, HURT}
var current_state: States = States.IDLE

# Facing properties
enum FacingDirection {RIGHT, LEFT}
var facing_direction: FacingDirection = FacingDirection.RIGHT

# Aiming properties
enum AimDirection {RIGHT, UP, LEFT, DOWN}
var current_aim_direction: AimDirection = AimDirection.RIGHT

# Animation tracking
var previous_animation: String = ""
var previous_facing: FacingDirection = FacingDirection.RIGHT
var previous_aim: AimDirection = AimDirection.RIGHT

################################################################################
# COMBAT PROPERTIES
################################################################################

# Shooting properties
var shoot_timer: float = 0.0

# Invulnerability properties
var is_invulnerable: bool = false

################################################################################
# SOUND PROPERTIES
################################################################################

var walk_snd_timer: float = 0.0
var walk_snd_interval: float = 0.3

################################################################################
# CORE FUNCTIONS
################################################################################

# Function that activates when the scene is ready.
func _ready() -> void:
	SpawnManager.set_player(self)
	GameState.register_player(self)
	# Connect to GameState signals.
	GameState.weapon_changed.connect(_on_weapon_changed)
	
	# Change position and avoid flicker on loading.
	if GameState.pending_player_position != Vector2.INF:
		global_position = GameState.pending_player_position
		GameState.pending_player_position = Vector2.INF

# Physics process.
func _physics_process(delta: float) -> void:
	GameState.player_is_on_floor = is_on_floor()
	
	if !is_on_floor() and !is_boosting:
		apply_gravity(delta)

	if not can_move or current_state == States.HURT:
		return # Skip processing if the player is hurt.

	# Update last safe position if on ground, and check coyote timing.
	if is_on_floor():
		safe_ground_timer += delta
		
		if safe_ground_timer >= 0.2 and not has_saved_safe_pos:
			last_safe_position = global_position
			has_saved_safe_pos = true
		
		coyote_timer = coyote_time
	else:
		safe_ground_timer = 0.0
		has_saved_safe_pos = false
		coyote_timer -= delta

	update_timers(delta)
	update_boost_timers(delta)
	GameState.update_boost_timers(delta)

	handle_movement_and_shooting(delta)
	handle_weapon_switching()

	# Check for interaction.
	if (current_state == States.IDLE and Input.is_action_pressed("aim_down") and is_on_floor()):
		handle_interaction()

	move_and_slide()
	animate_player()

################################################################################
# MOVEMENT FUNCTIONS
################################################################################

# Enables movement for the player.
func enable_movement() -> void:
	can_move = true
	if anim:
		anim.play() # Resume animations.
	current_state = States.IDLE # Reset to idle state.

# Applies gravity to the player.
func apply_gravity(delta: float) -> void:
	if !is_on_floor():
		velocity.y += gravity * delta

	# Shorten jump if the jump button is released early.
	if velocity.y < 0 and !Input.is_action_pressed("jump"):
		velocity.y += gravity * 2 * delta

	# Play bonk sound if the player hits the ceiling.
	if is_on_ceiling():
		SoundManager.play_sound(snd_bonk.stream)

# Updates the timers for shooting and walking sounds.
func update_timers(delta: float) -> void:
	shoot_timer -= delta
	walk_snd_timer -= delta

# Updates booster timers.
func update_boost_timers(delta: float) -> void:
	if boost_timer > 0:
		boost_timer -= delta
		if boost_timer <= 0:
			end_boost()

# Handles the player's movement and shooting.
func handle_movement_and_shooting(delta: float) -> void:
	# Reset from interact state if no longer pressing down.
	if current_state == States.INTERACT and !Input.is_action_pressed("aim_down"):
		current_state = States.IDLE

	var direction = Input.get_axis("move_left", "move_right")

	# Update facing direction based on movement input.
	if direction:
		facing_direction = FacingDirection.LEFT if direction < 0 else FacingDirection.RIGHT

	# Handle movement based on whether the player is on the ground or in the air.
	if is_on_floor():
		handle_ground_movement(direction, delta)
	else:
		handle_air_movement(direction, delta)
	
	# Handle jumping.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or coyote_timer > 0.0:
			# Regular jump
			velocity.y = jump_force
			current_state = States.JUMP
			SoundManager.play_sound(snd_jump.stream)
		elif GameState.is_booster_available():  # Now using GameState's check
			# Air boost
			GameState.start_boost()
			activate_boost()

	handle_aiming()

	# Handle shooting.
	if Input.is_action_just_pressed("shoot") and shoot_timer <= 0 and GameState.get_current_weapon():
		shoot_bullet()
		shoot_timer = GameState.get_current_weapon().cooldown
		update_shooting_state(direction)

# Handles ground movement.
func handle_ground_movement(direction: float, delta: float) -> void:
	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
		current_state = States.WALK_SHOOT if shoot_timer > 0 else States.WALK

		# Play walking sound at intervals.
		if walk_snd_timer <= 0:
			SoundManager.play_sound(snd_walk.stream)
			walk_snd_timer = walk_snd_interval
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		current_state = States.IDLE_SHOOT if shoot_timer > 0 else States.IDLE

# Handles air movement.
func handle_air_movement(direction: float, delta: float) -> void:
	if velocity.y > 0:
		current_state = States.FALL_SHOOT if shoot_timer > 0 else States.FALL
	else:
		current_state = States.JUMP_SHOOT if shoot_timer > 0 else States.JUMP
	velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)

################################################################################
# AIMING FUNCTIONS
################################################################################

# Handles the aiming input.
func handle_aiming() -> void:
	if Input.is_action_pressed("aim_up"):
		# Aim up.
		current_aim_direction = AimDirection.UP
		aim_node.rotation_degrees = 270
		aim_node.position = Vector2(0, -24) # Adjust position for aiming up.
	elif Input.is_action_pressed("aim_down") and !is_on_floor():
		# Aim down (only allowed in the air).
		current_aim_direction = AimDirection.DOWN
		aim_node.rotation_degrees = 90
		aim_node.position = Vector2(0, 16) # Adjust position for aiming down.
	else:
		# Default to facing direction (left or right).
		if facing_direction == FacingDirection.LEFT:
			# Facing left.
			current_aim_direction = AimDirection.LEFT
			aim_node.rotation_degrees = 180
			aim_node.position = Vector2(-16, -8) # Adjust position for facing left.
		else:
			# Facing right.
			current_aim_direction = AimDirection.RIGHT
			aim_node.rotation_degrees = 0
			aim_node.position = Vector2(16, -8) # Adjust position for facing right.

################################################################################
# WEAPON FUNCTIONS
################################################################################

# Handles the collection of weapon modules.
func collect_module(module_type: String) -> void:
	match module_type:
		"star_bullet":
			GameState.unlock_weapon("Star Bullet")
		"fireball":
			GameState.unlock_weapon("Fireball")
		"leaf_blower":
			GameState.unlock_weapon("Leaf Blower")
		"water_missile":
			GameState.unlock_weapon("Water Missile")

# Handles the weapon switching input.
func handle_weapon_switching() -> void:
	if Input.is_action_just_pressed("next_weapon"):
		GameState.switch_to_next_weapon()
	elif Input.is_action_just_pressed("previous_weapon"):
		GameState.switch_to_previous_weapon()

# Handles the weapon change event.
func _on_weapon_changed(new_weapon: String) -> void:
	if new_weapon != "":
		SoundManager.play_sound(snd_switch_weapon.stream)

# Handles the shooting action.
func shoot_bullet() -> void:
	if current_state == States.INTERACT or current_state == States.HURT:
		return

	var current_weapon = GameState.get_current_weapon()
	if current_weapon and shoot_timer <= 0:
		if current_weapon.name == "Leaf Blower":
			shoot_leaf_volley()
		else:
			var bullet = current_weapon.projectile_scene.instantiate() as Node2D
			bullet.global_position = aim_node.global_position
			bullet.direction = Vector2.RIGHT.rotated(aim_node.rotation)
			bullet.shooter = self
			get_tree().current_scene.add_child(bullet)
		
			# Play appropriate sounds.
			play_weapon_sound(current_weapon.name)
		
		shoot_timer = current_weapon.cooldown

# Update the shooting state based on the player's direction and state.
func update_shooting_state(direction: float) -> void:
	if is_on_floor():
		current_state = States.WALK_SHOOT if direction else States.IDLE_SHOOT
	else:
		current_state = States.JUMP_SHOOT if velocity.y < 0 else States.FALL_SHOOT

# Leaf volley.
func shoot_leaf_volley() -> void:
	var current_weapon = GameState.get_current_weapon()
	if !current_weapon:
		return
	
	# First leaf
	var leaf1 = current_weapon.projectile_scene.instantiate() as Node2D
	leaf1.global_position = aim_node.global_position
	leaf1.direction = Vector2.RIGHT.rotated(aim_node.rotation)
	leaf1.shooter = self
	get_tree().current_scene.add_child(leaf1)
	SoundManager.play_sound(snd_proj_leaf.stream)
	
	# Second leaf after small delay
	await get_tree().create_timer(0.05).timeout
	var leaf2 = current_weapon.projectile_scene.instantiate() as Node2D
	leaf2.global_position = aim_node.global_position
	# Slightly spread direction
	leaf2.direction = Vector2.RIGHT.rotated(aim_node.rotation + 0.1)
	leaf2.shooter = self
	get_tree().current_scene.add_child(leaf2)
	
	# Third leaf after small delay
	await get_tree().create_timer(0.05).timeout
	var leaf3 = current_weapon.projectile_scene.instantiate() as Node2D
	leaf3.global_position = aim_node.global_position
	# Slightly spread direction
	leaf3.direction = Vector2.RIGHT.rotated(aim_node.rotation - 0.1)
	leaf3.shooter = self
	get_tree().current_scene.add_child(leaf3)

# Plays the appropriate sound for the current weapon
func play_weapon_sound(weapon_name: String) -> void:
	match weapon_name:
		"Star Bullet":
			SoundManager.play_sound(snd_proj_star_bullet.stream)
		"Fireball":
			SoundManager.play_sound(snd_proj_fireball.stream)
		"Leaf Blower":
			SoundManager.play_sound(snd_proj_leaf.stream)
		"Water Missile":
			SoundManager.play_sound(snd_proj_water_missile.stream)

################################################################################
# INTERACTION FUNCTIONS
################################################################################

# Handles the player's interaction with objects.
func handle_interaction() -> void:
	# Only interact if completely idle (no movement input) and on ground.
	if (is_on_floor() and
		Input.is_action_pressed("aim_down") and
		!Input.is_action_pressed("move_left") and
		!Input.is_action_pressed("move_right") and
		abs(velocity.x) < 10):
		current_state = States.INTERACT
		velocity.x = 0

################################################################################
# DAMAGE FUNCTIONS
################################################################################

# Handles the player's collision with the enemy.
func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and not is_invulnerable:
		take_damage(body.damage_amount, body.global_position.x, false)

# Take damage.
func take_damage(damage: int, enemy_x: float, skip_knockback: bool = false) -> void:
	# Allow damage to go through if it's a pitfall and the player is at 1 HP.
	if is_invulnerable and not (skip_knockback and GameState.current_health == 1):
		return

	is_invulnerable = true

	GameState.decrease_health(damage)

	if GameState.current_health == 0:
		die()
	else:
		current_state = States.HURT
		anim.process_mode = Node.PROCESS_MODE_ALWAYS
		snd_hurt.process_mode = Node.PROCESS_MODE_ALWAYS
		SoundManager.play_sound(snd_hurt.stream)
		
		hurtbox_collision.call_deferred("set_disabled", true)

		# Only apply knockback if not skipping.
		if not skip_knockback:
			var knockback_direction = 1 if enemy_x < global_position.x else -1
			velocity = hurt_knockback * Vector2(knockback_direction, 1)

		await get_tree().process_frame
		
		get_tree().paused = true
		animate_hurt()
		await anim.animation_finished
		get_tree().paused = false
		
		anim.process_mode = Node.PROCESS_MODE_INHERIT

		# Start blinking and invulnerability timer.
		start_blinking()
		set_collision_layer_value(2, false)
		set_collision_mask_value(3, false)
		current_state = States.IDLE
		invuln_timer.start()

		# Wait for the invulnerability timer to finish.
		await invuln_timer.timeout

		# Stop blinking and reset invulnerability.
		stop_blinking()
		set_collision_layer_value(2, true)
		set_collision_mask_value(3, true)

		is_invulnerable = false
		sprite.visible = true
		
		hurtbox_collision.call_deferred("set_disabled", false)

# Starts blinking.
func start_blinking() -> void:
	blink_timer.start()

# Stops blinking.
func stop_blinking() -> void:
	blink_timer.stop()
	sprite.visible = true

# Handles the blink timer timeout event.
func _on_blink_timer_timeout() -> void:
	sprite.visible = !sprite.visible

# Handles the player's death.
func die() -> void:
	# Unpause the game and play the hurt sound effect.
	collision.call_deferred("set_disabled", true)
	hurtbox_collision.call_deferred("set_disabled", true)
	get_tree().paused = false
	anim.process_mode = Node.PROCESS_MODE_ALWAYS
	SoundManager.play_sound(snd_hurt.stream)

	# Disable processes.
	set_physics_process(false)
	set_process(false)

	# Pause the game and play the hurt animation.
	get_tree().paused = true
	animate_hurt()
	await anim.animation_finished
	get_tree().paused = false

	# Set visibility.
	visible = false
	
	# Stop current music and play the death sound effect.
	MusicManager.stop_music()
	var death_sound_player = SoundManager.play_sound(snd_death.stream)

	# Instantiate the entity death effect.
	var entity_death_instance = entity_death.instantiate() as Node2D
	entity_death_instance.global_position = global_position + sprite.position
	get_parent().add_child(entity_death_instance)

	await death_sound_player.finished
	GameManager.to_game_over()
	queue_free()
	
################################################################################
# PITFALL FUNCTIONS
################################################################################

# Checks if the player is in a pitfall area.
func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("pitfall"):
		handle_pitfall()

# Handles the player's collision with pitfalls.
func handle_pitfall() -> void:
	if GameState.current_health == 1:
		take_damage(1, global_position.x, true)
	else:
		teleport_player()

# Teleports the player to the last safe position.
func teleport_player() -> void:
	# Hide the player temporarily and pause processing.
	sprite.visible = false
	set_physics_process(false)

	# Teleport the player to the last safe position.
	global_position = last_safe_position
	velocity = Vector2.ZERO

	# Instantiate the teleport effect.
	var teleport_instance = teleport.instantiate() as Node2D
	teleport_instance.global_position = global_position + sprite.position
	get_parent().add_child(teleport_instance)
	
	# Show the player.
	sprite.visible = true
	
	await teleport_instance.teleport_finished

	# Take damage after teleporting back.
	await get_tree().create_timer(0.1).timeout
	take_damage(1, global_position.x, true)
	set_physics_process(true)

################################################################################
# BOOSTER FUNCTIONS
################################################################################

func activate_boost() -> void:
	is_boosting = true
	boost_timer = boost_duration  # Local timer for boost duration
	GameState.start_boost()  # This sets GameState's booster_active and cooldown timer
	
	# Reset velocity for clean boost
	velocity = Vector2.ZERO
	
	# Determine boost direction
	if Input.is_action_pressed("aim_up"):
		velocity.y = -boost_speed * 0.7
		current_state = States.JUMP
	elif Input.is_action_pressed("aim_down"):
		velocity.y = boost_speed * 0.5
		current_state = States.FALL
	else:
		# Horizontal boost
		var direction = 1 if facing_direction == FacingDirection.RIGHT else -1
		velocity.x = direction * boost_speed
		current_state = States.JUMP
	
	SoundManager.play_sound(snd_jump.stream)

func end_boost() -> void:
	is_boosting = false
	GameState.end_boost()  # Notify GameState boost ended
	
	if velocity.y < 0:
		current_state = States.JUMP
	else:
		current_state = States.FALL

################################################################################
# ANIMATION FUNCTIONS
################################################################################

# Handles the player's animation based on the current state and direction.
func animate_player() -> void:
	var animation_name = get_animation_name()
	# Handle interact animation separately since it should lock other animations.
	if current_state == States.INTERACT:
		animation_name = "interact_right" if facing_direction == FacingDirection.RIGHT else "interact_left"
		if anim.current_animation != animation_name:
			anim.play(animation_name)
	
	elif anim.current_animation != animation_name:
		var current_frame = anim.current_animation_position
		anim.play(animation_name)
	
		# Check if the new animation has the same facing and aiming directions as the previous one.
		if facing_direction == previous_facing and current_aim_direction == previous_aim:
			anim.play(animation_name)
			anim.seek(current_frame)
		else:
			anim.play(animation_name)
		
		# Update the previous animation tracking.
		previous_animation = animation_name
		previous_facing = facing_direction
		previous_aim = current_aim_direction

# Handles the player's hurt animation.
func animate_hurt() -> void:
	if facing_direction == FacingDirection.RIGHT:
		anim.play("hurt_right")
	else:
		anim.play("hurt_left")

# Gets the animation name based on the current state and direction.
func get_animation_name() -> String:
	var base_animation = ""
	match current_state:
		States.IDLE:
			base_animation = "idle"
		States.WALK:
			base_animation = "walk"
		States.JUMP:
			base_animation = "jump"
		States.FALL:
			base_animation = "fall"
		States.IDLE_SHOOT:
			base_animation = "idle_shoot"
		States.WALK_SHOOT:
			base_animation = "walk_shoot"
		States.JUMP_SHOOT:
			base_animation = "jump_shoot"
		States.FALL_SHOOT:
			base_animation = "fall_shoot"
		States.INTERACT:
			base_animation = "interact"

	# Determine the facing direction.
	var facing = "right" if facing_direction == FacingDirection.RIGHT else "left"

	# Append the aiming direction to the base animation name.
	match current_aim_direction:
		AimDirection.UP:
			return base_animation + "_" + facing + "_up"
		AimDirection.DOWN:
			return base_animation + "_" + facing + "_down"
		AimDirection.LEFT:
			return base_animation + "_" + facing + "_left"
		AimDirection.RIGHT:
			return base_animation + "_" + facing + "_right"

	return base_animation + "_" + facing
