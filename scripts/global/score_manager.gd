extends Node

# Score variables.
var score: int = 0

# Signals.
signal score_updated(new_score)
signal score_reset()

# Increments the score.
func increment_score(increment: int) -> void:
	score += increment
	print("Score: ", score)
	emit_signal("score_updated", score)

# Resets the score.
func reset_score() -> void:
	score = 0
	print("Score: ", score)
	emit_signal("score_reset")
	emit_signal("score_updated", score)
