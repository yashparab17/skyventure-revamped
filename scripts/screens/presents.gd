extends CanvasLayer

# Node references.
@onready var anim: AnimationPlayer = $Animator
@onready var loading_label: Label = $LoadingLabel
@onready var presents_text: TextureRect = $PresentsText

func _ready() -> void:
	presents_text.hide()
	
	GameLoader.loading_progress.connect(_update_loading_text)
	GameLoader.loading_complete.connect(_finish_loading)
	GameLoader.start_loading()
	
	anim.play("loading")

func _update_loading_text(message: String) -> void:
	loading_label.text = message

func _finish_loading() -> void:
	loading_label.hide()
	anim.play("presents")
	await anim.animation_finished
	exit()

func exit() -> void:
	GameManager.transition_to_scene("res://scenes/screens/main_menu.tscn")
