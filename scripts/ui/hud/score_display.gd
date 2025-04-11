# score_display.gd
extends Control

@onready var score_text: Label = $ScoreText
#@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	# Initialize with current score
	score_text.text = str(GameState.score)

func update_score(new_value: int):
	var start_value := int(score_text.text) if score_text.text != "" else 0
	var tween = create_tween()
	tween.tween_method(
		func(value: float): score_text.text = str(int(value)),
		start_value, new_value, 0.33
	)
	#tween.finished.connect(_on_score_tween_finished)
#
#func _on_score_tween_finished():
	#animation_player.play("pulse")
