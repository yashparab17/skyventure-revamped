extends CanvasLayer

# Node references.
@onready var anim: AnimationPlayer = $Animator

# Scene variables.
var main_menu = preload("res://scenes/screens/main_menu.tscn")

func _ready() -> void:
	anim.play("presents")
	await anim.animation_finished
	exit()
	
func exit() -> void:
	GameManager.transition_to_scene(main_menu.resource_path)
