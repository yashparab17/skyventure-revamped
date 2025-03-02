extends CharacterBody2D

@export var health_amount: int = 5
@export var damage_amount: int = 1

var player_ref: Node2D = null

@onready var sprite = $Sprite
@onready var anim = $Animation
@onready var detection_area = $DetectionArea

var entity_death = preload("res://scenes/effects/entity_death.tscn")

enum States {idle, hurt, death}
var current_state: States = States.idle

func _ready():
	# Try to find the player in the scene.
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_ref = players[0]  # Assign the first player found
		face_player()  # Face the player immediately
			
func _physics_process(delta: float) -> void:
	if player_ref:
		face_player()

func face_player():
	if player_ref:
		sprite.flip_h = player_ref.global_position.x < global_position.x
		
func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(damage_amount, global_position.x)

func _on_hurtbox_area_entered(area: Area2D) -> void:
	print("Hit detected with:", area.get_parent().name)  # Debugging line
	
	if area.get_parent().has_method("get_damage_amount"):
		var bullet = area.get_parent() as Node
		var bullet_damage = bullet.damage_amount
		print("Health before hit:", health_amount)
		health_amount -= bullet_damage
		print("Health after hit:", health_amount)
		
		current_state = States.hurt
		anim.play("hurt")
		
		if health_amount <= 0:
			print("Health reached 0! Calling die()")
			die()

func die():
	current_state = States.death
	anim.play("death")
	await anim.animation_finished
	var entity_death_instance = entity_death.instantiate()
	entity_death_instance.global_position = global_position + sprite.position
	get_parent().add_child(entity_death_instance)
	queue_free()
