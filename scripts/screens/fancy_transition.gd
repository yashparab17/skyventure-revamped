extends CanvasLayer

# Signal to indicate the transition is finished.
signal transition_finished

# Node references.
@onready var anim = $Animator

# Entering animation.
func play_in() -> void:
	anim.play("wipe_in")
	await anim.animation_finished
	emit_signal("transition_finished")

# Exiting animation.
func play_out() -> void:
	anim.play("wipe_out")
	await anim.animation_finished
	queue_free()
