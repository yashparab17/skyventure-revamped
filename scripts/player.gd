extends CharacterBody2D

# Preload bullet scene.
var bullet_1 = preload("res://scenes/projectiles/bullet_1.tscn")

# Player movement properties.
@export var gravity = 600
@export var speed: int = 200
@export var jump_force: int = -300
@export var acceleration: float = 600
@export var friction: float = 800

# Node references.
@onready var sprite: Sprite2D = $Sprite
@onready var anim: AnimationPlayer = $Animation
@onready var muzzle: Marker2D = $Muzzle

# State machine.
enum States {idle, walk, jump, fall, idle_shoot, walk_shoot}
var current_state: States

# Shooting properties.
var muzzle_position
var shoot_cooldown = 0.2
var shoot_timer = 0.0

func _ready() -> void:
	current_state = States.idle
	muzzle_position = muzzle.position

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

	# Flip sprite and adjust muzzle position based on movement direction.
	if direction:
		sprite.flip_h = direction < 0
		muzzle.position.x = abs(muzzle_position.x) * (1 if direction > 0 else -1)

	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_force
			current_state = States.jump
		elif direction:
			velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
			
			if Input.is_action_just_pressed("shoot"):
				shoot_bullet(direction)
				shoot_timer = shoot_cooldown
				current_state = States.walk_shoot
			elif shoot_timer > 0:
				current_state = States.walk_shoot
			else:
				current_state = States.walk
		else:
			velocity.x = move_toward(velocity.x, 0, friction * delta)

			if Input.is_action_just_pressed("shoot"):
				shoot_bullet(1 if not sprite.flip_h else -1)
				shoot_timer = shoot_cooldown
				current_state = States.idle_shoot
			elif shoot_timer > 0:
				current_state = States.idle_shoot
			else:
				current_state = States.idle
	else:
		if velocity.y > 0:
			current_state = States.fall

		if direction:
			velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, friction * delta)

# Spawns and shoots a bullet in the given direction.
func shoot_bullet(direction: float):
	var bullet_1_instance = bullet_1.instantiate() as Node2D
	bullet_1_instance.direction = direction
	bullet_1_instance.global_position = muzzle.global_position
	get_parent().add_child(bullet_1_instance)

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
