extends Control

# Node references.
@onready var score_text: Label = $ScoreText

# Updates score with an animation.
func update_score(new_value: int):
	var start_value := int(score_text.text) if score_text.text != "" else 0
	var tween = create_tween()
	tween.tween_method(
		func(value: float): score_text.text = str(int(value)),
		start_value, new_value, 0.33
	)
