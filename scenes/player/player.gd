extends CharacterBody2D

# Export variables.
@export var gravity = 600
@export var speed : int = 200
@export var jump_force : int = -300
@export var acceleration: float = 600
@export var friction: float = 800

# Ready variables.
@onready var sprite = $Sprite
@onready var anim = $Animation

# Code relating to the state machine.
enum States { idle, walk, jump, fall }
var current_state : States

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_state = States.idle

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	apply_gravity(delta)

	player_move(delta)

	move_and_slide()

	animate_player()

	print("State: ", States.keys()[current_state])	

func apply_gravity(delta: float):
	if !is_on_floor():
		velocity.y += gravity * delta

func player_move(delta: float):
	var direction = Input.get_axis("move_left", "move_right")

	if direction:
		sprite.flip_h = false if direction > 0 else true

	if is_on_floor():
		# Jump state.
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_force
			current_state = States.jump
		# Walk state.
		elif direction:
			velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
			current_state = States.walk
		# Idle state.
		else:
			velocity.x = move_toward(velocity.x, 0, friction * delta)
			current_state = States.idle
	else:
		# Fall state.
		if velocity.y > 0:
			current_state = States.fall
		if direction:
			velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, friction * delta)

func animate_player():
	if current_state == States.idle:
		anim.play("idle")
	elif current_state == States.walk:
		anim.play("walk")
	elif current_state == States.jump:
		anim.play("jump")
	elif current_state == States.fall:
		anim.play("fall")
