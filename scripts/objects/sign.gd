extends Sprite2D

@export var text: String

# Node references.
@onready var message_box: TextureRect = $MessageBox
@onready var anim: AnimationPlayer = $Animator
@onready var message_text: Label = $MessageBox/Margin/Text

# Variables for state tracking.
var player_inside := false
var is_animating := false

# Hides the message box and sets the appropriate text.
func _ready() -> void:
	message_box.hide()
	message_text.text = text

# Called when the player enters the area.
func _on_interactable_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not player_inside:
		player_inside = true
		appear()

# Called when the player exits the area.
func _on_interactable_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false
		try_disappear_later()

# Plays the appear animation and displays the message box.
func appear() -> void:
	if is_animating:
		return
	is_animating = true
	message_box.show()
	anim.play("appear")
	await anim.animation_finished
	is_animating = false
	
	if not player_inside:
		disappear()

# Helper function to make sure the message box disappears.
func try_disappear_later() -> void:
	await get_tree().process_frame
	if is_animating:
		await anim.animation_finished
	if not player_inside:
		disappear()

# Plays the disappear animation and hides the message box.
func disappear() -> void:
	if is_animating:
		return
	is_animating = true
	anim.play("disappear")
	await anim.animation_finished
	message_box.hide()
	is_animating = false
