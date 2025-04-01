extends CanvasLayer

@onready var container: VBoxContainer = $ScrollContainer/VBoxContainer

func _ready():
	display_scores()

func display_scores():
	var scores = ScoreAccess.load_scores()
	
	# Clear existing children.
	for child in container.get_children():
		child.queue_free()
	
	# Add each score.
	for i in range(scores.size()):
		var entry = scores[i]
		var label = Label.new()
		label.text = "%d. %s - %d" % [i+1, entry["name"], entry["score"]]
		container.add_child(label)
