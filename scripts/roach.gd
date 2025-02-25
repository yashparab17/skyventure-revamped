extends CharacterBody2D

# Export variables.
@export var gravity = 600
@export var speed : int = 50
@export var acceleration: float = 600
@export var friction: float = 800

# Setting the direction (Default: Left).
var direction: Vector2 = Vector2.LEFT

# Patrol point variables.
@export var patrol_points : Node
@export var wait_time : int = 3
var no_of_points: int
var point_positions: Array[Vector2]
var current_point: Vector2
var current_point_position: int

# Ready variables.
@onready var sprite = $Sprite
@onready var anim = $Animation
@onready var timer = $Timer

# Code relating to the state machine.
enum States { idle, walk }
var current_state : States
var can_walk: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if patrol_points != null:
		no_of_points = patrol_points.get_children().size()
		for point in patrol_points.get_children():
			point_positions.append(point.global_position)
		current_point = point_positions[current_point_position]
	else:
		print("No patrol points available.")

	timer.wait_time = wait_time
		
	current_state = States.idle

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	if can_walk:
		roach_patrol(delta)
	move_and_slide()
	animate_roach()

	print("State: ", States.keys()[current_state])	

func apply_gravity(delta: float):
	if !is_on_floor():
		velocity.y += gravity * delta

# Enemy patrol logic focused on patrol points.
func roach_patrol(delta: float):
	if point_positions.size() == 0:
		return

	var target_point = point_positions[current_point_position]
	direction = (target_point - global_position).normalized()

	# Flip sprite based on direction
	sprite.flip_h = direction.x < 0

	# Move towards the target patrol point
	velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)
	current_state = States.walk

	# Check if close enough to the patrol point
	if global_position.distance_to(target_point) < 5:
		can_walk = false  # Stop moving
		velocity.x = 0  # Stop horizontal movement
		current_state = States.idle
		timer.start()  # Start the pause timer

func animate_roach():
	if current_state == States.idle:
		anim.play("idle")
	elif current_state == States.walk:
		anim.play("walk")

func _on_timer_timeout() -> void:
	can_walk = true
	current_point_position = (current_point_position + 1) % no_of_points
