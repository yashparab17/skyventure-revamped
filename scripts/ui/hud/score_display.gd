extends Control

# Node references.
@onready var score_text: Label = $Background/ScoreText

# Sets score value to zero
func _ready() -> void:
	score_text.text = "0"

func update_score(new_value: int) -> void:
	# Animation for updating score.
	var start_value := int(score_text.text) if score_text.text != "" else 0
	var duration := 0.33
	
	var tween = create_tween()
	tween.tween_method(
		func(value: float): 
			score_text.text = str(int(value)),
		start_value, new_value, duration
	)
