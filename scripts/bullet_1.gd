extends AnimatedSprite2D

# Bullet properties.
@export var speed: int = 500
@export var direction: int
@export var damage_amount: int = 1

# Preloads the bullet impact effect.
var bullet_1_impact = preload("res://scenes/effects/bullet_1_impact.tscn")

func _physics_process(delta: float) -> void:
	# Moves the bullet in the set direction every frame.
	move_local_x(direction * speed * delta)

# Deletes the bullet when the timer runs out.
func _on_timer_timeout() -> void:
	queue_free()

# Returns the damage amount of the bullet.
func get_damage_amount() -> int:
	return damage_amount

# Handles collision when the bullet hits an area.
func _on_hitbox_area_entered() -> void:
	bullet_impact()

# Handles collision when the bullet hits a body.
func _on_hitbox_body_entered() -> void:
	bullet_impact()

# Creates the bullet impact effect and deletes the bullet.
func bullet_impact():
	var bullet_1_impact_instance = bullet_1_impact.instantiate() as Node2D
	bullet_1_impact_instance.global_position = global_position
	get_parent().add_child(bullet_1_impact_instance)
	queue_free()
