extends Node2D

# Node references.
@export var bullet_scene: PackedScene = preload("res://scenes/projectiles/bullet_1.tscn")
@onready var muzzle = $Muzzle
@onready var snd_shoot = $Sounds/Shoot

# Bullet properties.
@export var cooldown: float = 0.2
@export var shoot_offset: Vector2 = Vector2(2, -2)

# Shooting state.
var can_shoot: bool = true
var original_position: Vector2

# Shooter reference.
var shooter: CharacterBody2D = null

func _ready() -> void:
    original_position = position # Store the original position of the gun.

# Shoots a bullet in the given direction if not on cooldown.
func shoot(direction: float) -> void:
    if can_shoot:
        can_shoot = false
        raise_gun()
        play_shoot_sound()
        spawn_bullet(direction)
        await cooldown_timer()
        lower_gun()
        can_shoot = true

# Plays the shooting sound effect.
func play_shoot_sound() -> void:
    snd_shoot.play()

# Spawns a bullet and adds it to the scene.
func spawn_bullet(direction: float) -> void:
    if bullet_scene != null:
        var bullet = bullet_scene.instantiate() as Node2D
        bullet.global_position = muzzle.global_position
        bullet.direction = direction

        # Set shooter reference to the gun's owner (should be the player).
        if owner is CharacterBody2D:
            bullet.shooter = owner

        get_tree().current_scene.add_child(bullet)

# Waits for the cooldown timer to finish.
func cooldown_timer() -> void:
    await get_tree().create_timer(cooldown).timeout

# Temporarily raises the gun when shooting.
func raise_gun() -> void:
    var flip_multiplier = -1 if $Sprite.flip_h else 1
    position += Vector2(shoot_offset.x * flip_multiplier, shoot_offset.y)

# Resets the gun position after shooting.
func lower_gun() -> void:
    position = original_position

# Flips the muzzle when the player changes direction.
func flip_muzzle(flip: bool) -> void:
    $Sprite.flip_h = flip
    $Muzzle.position.x = - abs($Muzzle.position.x) if flip else abs($Muzzle.position.x)