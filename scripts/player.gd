extends CharacterBody2D

# Preload bullet and gun scenes.
var bullet_1 = preload("res://scenes/projectiles/bullet_1.tscn")
var gun_scene = preload("res://scenes/items/gun_1.tscn")
var gun_instance = null

# Player movement properties.
@export var gravity = 600
@export var speed: int = 200
@export var jump_force: int = -300
@export var acceleration: float = 600
@export var friction: float = 800

# Node references.
@onready var sprite: Sprite2D = $Sprite
@onready var anim: AnimationPlayer = $Animation
@onready var gun_hold_position: Marker2D = $GunHoldPosition

# State machine.
enum States {idle, walk, jump, fall, idle_shoot, walk_shoot}
var current_state: States = States.idle

# Shooting properties.
var shoot_cooldown = 0.2
var shoot_timer = 0.0

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	shoot_timer -= delta

	handle_movement_and_shooting(delta)

	move_and_slide()
	animate_player()

# Applies gravity if the player is not on the floor.
func apply_gravity(delta: float):
	if !is_on_floor():
		velocity.y += gravity * delta

# Handles movement, jumping, and shooting logic.
func handle_movement_and_shooting(delta: float):
	var direction = Input.get_axis("move_left", "move_right")

	# Flip sprite, gun hold position, and gun when changing direction.
	if direction:
		sprite.flip_h = direction < 0
		gun_hold_position.position.x = -8 if sprite.flip_h else 8
		flip_gun(sprite.flip_h)

	# Movement logic.
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_force
			current_state = States.jump
		else:
			handle_ground_movement(direction, delta)
	else:
		handle_air_movement(direction, delta)

# Handles movement while on the ground.
func handle_ground_movement(direction: float, delta: float):
	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
		current_state = States.walk_shoot if shoot_timer > 0 else States.walk
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		current_state = States.idle_shoot if shoot_timer > 0 else States.idle

	if gun_instance and Input.is_action_just_pressed("shoot") and shoot_timer <= 0:
		shoot_bullet(1 if not sprite.flip_h else -1)
		shoot_timer = shoot_cooldown
		current_state = States.walk_shoot if direction else States.idle_shoot

# Handles movement while in the air.
func handle_air_movement(direction: float, delta: float):
	if velocity.y > 0:
		current_state = States.fall
	velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)

# Spawns and shoots a bullet using the gun instance.
func shoot_bullet(direction: float):
	if gun_instance:
		gun_instance.shoot(direction)

# Function to collect and attach a gun to the player.
func collect_gun():
	if not gun_instance:
		gun_instance = gun_scene.instantiate()
		gun_hold_position.add_child(gun_instance)

		# Ensure the gun is positioned correctly.
		gun_instance.position = Vector2.ZERO
		gun_instance.scale.x = 1
		gun_instance.owner = self

		flip_gun(sprite.flip_h)

# Flips the gun when the player flips direction.
func flip_gun(flip: bool):
	if gun_instance:
		gun_instance.flip_muzzle(flip)

# Updates animation based on player state.
func animate_player():
	var current_frame = anim.current_animation_position

	match current_state:
		States.idle:
			if anim.current_animation != "idle":
				anim.play("idle")
		States.walk:
			if anim.current_animation != "walk":
				anim.play("walk")
				anim.seek(current_frame, true)
		States.idle_shoot:
			if anim.current_animation != "idle_shoot":
				anim.play("idle_shoot")
		States.walk_shoot:
			if anim.current_animation != "walk_shoot":
				anim.play("walk_shoot")
				anim.seek(current_frame, true)
		States.jump:
			if anim.current_animation != "jump":
				anim.play("jump")
		States.fall:
			if anim.current_animation != "fall":
				anim.play("fall")
