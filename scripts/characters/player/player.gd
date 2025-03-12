extends CharacterBody2D

# Preload scenes for projectiles and effects.
var bullet_1 = preload("res://scenes/projectiles/bullet_1.tscn")
var entity_death = preload("res://scenes/effects/entity_death.tscn")

# Player movement properties.
@export var gravity: float = 600
@export var speed: int = 200
@export var jump_force: int = -300
@export var acceleration: float = 600
@export var friction: float = 800
@export var hurt_knockback: Vector2 = Vector2(200, -200)
@export var hurt_duration: float = 0.5

# Node references.
@onready var sprite: Sprite2D = $Sprite
@onready var anim: AnimationPlayer = $Animation
@onready var aim_node: Node2D = $AimNode

# Sound references.
@onready var snd_walk = $Sounds/Walk
@onready var snd_jump = $Sounds/Jump
@onready var snd_bonk = $Sounds/Bonk
@onready var snd_hurt = $Sounds/Hurt
@onready var snd_death = $Sounds/Death
@onready var snd_proj_bull = $Sounds/ProjBullet

# Sound properties.
var walk_snd_timer: float = 0.0
@export var walk_snd_interval: float = 0.3

# State machine.
enum States {IDLE, WALK, JUMP, FALL, IDLE_SHOOT, WALK_SHOOT, JUMP_SHOOT, FALL_SHOOT, HURT}
var current_state: States = States.IDLE

# Aiming properties.
enum AimDirection {RIGHT, UP, LEFT, DOWN}
var current_aim_direction: AimDirection = AimDirection.RIGHT

# Shooting properties.
var shoot_cooldown: float = 0.2
var shoot_timer: float = 0.0

# Invulnerability properties.
var is_invulnerable: bool = false

func _physics_process(delta: float) -> void:
	if current_state == States.HURT:
		return # Skip processing if the player is hurt.

	apply_gravity(delta)
	update_timers(delta)
	handle_movement_and_shooting(delta)
	move_and_slide()
	animate_player()

# Applies gravity to the player if not on the floor.
func apply_gravity(delta: float) -> void:
	if !is_on_floor():
		velocity.y += gravity * delta

	# Shorten jump if the jump button is released early.
	if velocity.y < 0 and !Input.is_action_pressed("jump"):
		velocity.y += gravity * 2 * delta

	# Play bonk sound if the player hits the ceiling.
	if is_on_ceiling():
		snd_bonk.play()

# Updates timers for shooting and walking sounds.
func update_timers(delta: float) -> void:
	shoot_timer -= delta
	walk_snd_timer -= delta

# Handles player movement, jumping, and shooting.
func handle_movement_and_shooting(delta: float) -> void:
	var direction = Input.get_axis("move_left", "move_right")

	# Flip sprite when changing direction.
	if direction:
		sprite.flip_h = direction < 0

	# Handle movement based on whether the player is on the ground or in the air.
	if is_on_floor():
		handle_ground_movement(direction, delta)
	else:
		handle_air_movement(direction, delta)

	handle_aiming()

	# Handle shooting.
	if Input.is_action_just_pressed("shoot") and shoot_timer <= 0:
		shoot_bullet()
		shoot_timer = shoot_cooldown
		update_shooting_state(direction)

# Handles movement while on the ground.
func handle_ground_movement(direction: float, delta: float) -> void:
	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
		current_state = States.WALK_SHOOT if shoot_timer > 0 else States.WALK

		# Play walking sound at intervals.
		if walk_snd_timer <= 0:
			snd_walk.play()
			walk_snd_timer = walk_snd_interval
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		current_state = States.IDLE_SHOOT if shoot_timer > 0 else States.IDLE
		walk_snd_timer = 0

	# Handle jumping.
	if Input.is_action_just_pressed("jump"):
		velocity.y = jump_force
		current_state = States.JUMP
		snd_jump.play()

# Handles movement while in the air.
func handle_air_movement(direction: float, delta: float) -> void:
	if velocity.y > 0:
		current_state = States.FALL_SHOOT if shoot_timer > 0 else States.FALL
	else:
		current_state = States.JUMP_SHOOT if shoot_timer > 0 else States.JUMP
	velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)

# Handles aiming.
func handle_aiming() -> void:
	if Input.is_action_pressed("aim_up"):
		# Aim up.
		current_aim_direction = AimDirection.UP
		aim_node.rotation_degrees = 270
		aim_node.position = Vector2(0, -16) # Adjust position for aiming up.
	elif Input.is_action_pressed("aim_down") and !is_on_floor():
		# Aim down (only allowed in the air).
		current_aim_direction = AimDirection.DOWN
		aim_node.rotation_degrees = 90
		aim_node.position = Vector2(0, 16) # Adjust position for aiming down.
	else:
		# Default to facing direction (left or right).
		if sprite.flip_h:
			# Facing left.
			current_aim_direction = AimDirection.LEFT
			aim_node.rotation_degrees = 180
			aim_node.position = Vector2(-8, -8) # Adjust position for facing left.
		else:
			# Facing right.
			current_aim_direction = AimDirection.RIGHT
			aim_node.rotation_degrees = 0
			aim_node.position = Vector2(8, -8) # Adjust position for facing right.

# Shoots a bullet in the specified direction.
func shoot_bullet() -> void:
	if shoot_timer <= 0:
		var bullet = bullet_1.instantiate() as Node2D
		bullet.global_position = aim_node.global_position # Use AimNode's position.
		bullet.direction = Vector2.RIGHT.rotated(aim_node.rotation) # Use AimNode's rotation.
		bullet.shooter = self
		snd_proj_bull.play()
		get_tree().current_scene.add_child(bullet)
		shoot_timer = shoot_cooldown

# Updates the player's state when shooting.
func update_shooting_state(direction: float) -> void:
	if is_on_floor():
		current_state = States.WALK_SHOOT if direction else States.IDLE_SHOOT
	else:
		current_state = States.JUMP_SHOOT if velocity.y < 0 else States.FALL_SHOOT

# Handles collision with the hurtbox.
func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and not is_invulnerable:
		take_damage(body.damage_amount, body.global_position.x)

# Handles player taking damage.
func take_damage(damage: int, enemy_x: float) -> void:
	is_invulnerable = true
	HealthManager.decrease_health(damage)

	if HealthManager.current_health == 0:
		die()
	else:
		current_state = States.HURT
		anim.process_mode = Node.PROCESS_MODE_ALWAYS
		snd_hurt.process_mode = Node.PROCESS_MODE_ALWAYS
		anim.play("hurt")
		snd_hurt.play()

		# Apply knockback based on enemy position.
		var knockback_direction = 1 if enemy_x < global_position.x else -1
		velocity = hurt_knockback * Vector2(knockback_direction, 1)

		await get_tree().process_frame
		get_tree().paused = true
		await anim.animation_finished
		get_tree().paused = false
		anim.process_mode = Node.PROCESS_MODE_INHERIT

		is_invulnerable = false
		current_state = States.IDLE

# Handles player death.
func die() -> void:
	get_tree().paused = false
	anim.process_mode = Node.PROCESS_MODE_ALWAYS
	snd_hurt.process_mode = Node.PROCESS_MODE_ALWAYS
	anim.play("hurt")
	snd_hurt.play()
	get_tree().paused = true
	await anim.animation_finished
	get_tree().paused = false

	visible = false
	set_physics_process(false)
	set_process(false)
	snd_death.play()

	var entity_death_instance = entity_death.instantiate() as Node2D
	entity_death_instance.global_position = global_position + sprite.position
	get_parent().add_child(entity_death_instance)

	await snd_death.finished
	queue_free()

# Updates the player's animation based on the current state.
func animate_player() -> void:
	var current_frame = anim.current_animation_position

	match current_state:
		States.IDLE:
			if anim.current_animation != "idle":
				anim.play("idle")
		States.WALK:
			if anim.current_animation != "walk":
				anim.play("walk")
				anim.seek(current_frame, true)
		States.JUMP:
			if anim.current_animation != "jump":
				anim.play("jump")
		States.FALL:
			if anim.current_animation != "fall":
				anim.play("fall")
				anim.seek(current_frame, true)
		States.IDLE_SHOOT:
			if anim.current_animation != "idle_shoot":
				anim.play("idle_shoot")
		States.WALK_SHOOT:
			if anim.current_animation != "walk_shoot":
				anim.play("walk_shoot")
				anim.seek(current_frame, true)
		States.JUMP_SHOOT:
			if anim.current_animation != "jump_shoot":
				anim.play("jump_shoot")
		States.FALL_SHOOT:
			if anim.current_animation != "fall_shoot":
				anim.play("fall_shoot")
				anim.seek(current_frame, true)
		States.HURT:
			if anim.current_animation != "hurt":
				anim.play("hurt")
