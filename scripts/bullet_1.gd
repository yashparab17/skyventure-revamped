extends AnimatedSprite2D

# Export variables.
@export var speed : int = 500
@export var direction: int 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	move_local_x(direction * speed * delta)

func _on_timer_timeout() -> void:
	queue_free()
