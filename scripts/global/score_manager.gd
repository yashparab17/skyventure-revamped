extends Node

# Score variables.
var score: int = 0

# Increments the score.
func increment_score(increment: int) -> void:
	score += increment
	print("Score: ", score)
	Signals.emit_signal("score_updated", score)

# Resets the score.
func reset_score() -> void:
	score = 0
	print("Score: ", score)
	Signals.emit_signal("score_reset")
	Signals.emit_signal("score_updated", score)
