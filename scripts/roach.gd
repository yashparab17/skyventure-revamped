extends CharacterBody2D

# Enemy movement properties.
@export var gravity = 600
@export var speed: int = 50
@export var acceleration: float = 600
@export var friction: float = 800

# Patrol system.
@export var patrol_points: Node # Parent node containing patrol points.
@export var wait_time: int = 3 # Time to wait at each patrol point.
var no_of_points: int = 0
var point_positions: Array[Vector2] = []
var current_point_position: int = 0

# Direction and movement state.
var direction: Vector2 = Vector2.LEFT
var can_walk: bool = true

# Node references.
@onready var sprite = $Sprite
@onready var anim = $Animation
@onready var timer = $Timer

# State machine.
enum States {idle, walk}
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

	if can_walk:
		roach_patrol(delta)

	move_and_slide()
	animate_roach()

# Applies gravity if the enemy is airborne.
func apply_gravity(delta: float):
	if !is_on_floor():
		velocity.y += gravity * delta

# Patrol logic, moving between defined patrol points.
func roach_patrol(delta: float):
	if point_positions.is_empty():
		return

	var target_point = point_positions[current_point_position]
	direction = (target_point - global_position).normalized()

	# Flip sprite based on movement direction.
	sprite.flip_h = direction.x < 0

	# Move towards the patrol point.
	velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)
	current_state = States.walk

	# Stop moving when close enough to the target.
	if global_position.distance_to(target_point) < 5:
		can_walk = false
		velocity.x = 0
		current_state = States.idle
		timer.start()

# Updates animation based on current state.
func animate_roach():
	match current_state:
		States.idle:
			if anim.current_animation != "idle":
				anim.play("idle")
		States.walk:
			if anim.current_animation != "walk":
				anim.play("walk")

# Resumes movement after waiting at a patrol point.
func _on_timer_timeout() -> void:
	can_walk = true
	current_point_position = (current_point_position + 1) % no_of_points
