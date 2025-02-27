extends Node2D

# Node references.
@export var bullet_scene: PackedScene = preload("res://scenes/projectiles/bullet_1.tscn")

# Bullet variables.
@export var cooldown: float = 0.2
@export var shoot_offset: Vector2 = Vector2(0, -2)
@onready var muzzle = $Muzzle
var can_shoot = true
var original_position: Vector2

func _ready():
	original_position = position

# Fires a bullet in the given direction if not on cooldown.
func shoot(direction: float):
	if can_shoot:
		can_shoot = false
		raise_gun()

		# Instantiates the bullet and adds it to the scene.
		if bullet_scene != null:
			var bullet = bullet_scene.instantiate() as Node2D
			bullet.global_position = muzzle.global_position
			bullet.direction = direction
			get_tree().current_scene.add_child(bullet)

		# Cooldown timer.
		await get_tree().create_timer(cooldown).timeout
		lower_gun()
		can_shoot = true

# Temporarily raises the gun when shooting.
func raise_gun():
	position += Vector2(0, shoot_offset.y)

# Resets the gun position.
func lower_gun():
	position = original_position

# Flips the muzzle when player changes direction.
func flip_muzzle(flip: bool):
	$Sprite.flip_h = flip

	if flip:
		$Muzzle.position.x = - abs($Muzzle.position.x)
	else:
		$Muzzle.position.x = abs($Muzzle.position.x)
