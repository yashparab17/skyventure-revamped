extends CharacterBody2D

# Preloading variables.
var bullet_1 = preload("res://scenes/projectiles/bullet_1.tscn")

# Export variables.
@export var gravity = 600
@export var speed : int = 200
@export var jump_force : int = -300
@export var acceleration: float = 600
@export var friction: float = 800

# Ready variables.
@onready var sprite : Sprite2D = $Sprite
@onready var anim : AnimationPlayer = $Animation
@onready var muzzle : Marker2D = $Muzzle

# Variables relating to the state machine.
enum States { idle, walk, jump, fall, idle_shoot, walk_shoot }
var current_state : States

# Shooting variables.
var muzzle_position
var shoot_cooldown = 0.2  # Time in seconds to stay in shoot state
var shoot_timer = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_state = States.idle
	muzzle_position = muzzle.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	shoot_timer -= delta  # Decrease the shoot timer
	handle_movement_and_shooting(delta)
	move_and_slide()
	animate_player()

func apply_gravity(delta: float):
	if !is_on_floor():
		velocity.y += gravity * delta

# Combines movement, muzzle positioning, and shooting into one streamlined function.
func handle_movement_and_shooting(delta: float):
	var direction = Input.get_axis("move_left", "move_right")

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
				shoot_timer = shoot_cooldown  # Reset the shoot timer
				current_state = States.walk_shoot
			elif shoot_timer > 0:
				current_state = States.walk_shoot  # Stay in walk_shoot until cooldown ends
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

# Handles shooting mechanics.
func shoot_bullet(direction: float):
	var bullet_1_instance = bullet_1.instantiate() as Node2D
	bullet_1_instance.direction = direction
	bullet_1_instance.global_position = muzzle.global_position
	get_parent().add_child(bullet_1_instance)

# Animates the player based on the current state.
func animate_player():
	var current_frame = anim.current_animation_position  # Store the current animation frame

	if current_state == States.idle:
		if anim.current_animation != "idle":
			anim.play("idle")
	elif current_state == States.walk:
		if anim.current_animation != "walk":
			anim.play("walk")
			anim.seek(current_frame, true)  # Resume from the same frame
	elif current_state == States.idle_shoot:
		if anim.current_animation != "idle_shoot":
			anim.play("idle_shoot")
	elif current_state == States.walk_shoot:
		if anim.current_animation != "walk_shoot":
			anim.play("walk_shoot")
			anim.seek(current_frame, true) 
	elif current_state == States.jump:
		if anim.current_animation != "jump":
			anim.play("jump")
	elif current_state == States.fall:
		if anim.current_animation != "fall":
			anim.play("fall")
