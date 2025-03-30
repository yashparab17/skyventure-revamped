extends CanvasLayer

# Module variables.
var module_name: String = "Module Name"
var module_description: String = "Module Description"

# Node references.
@onready var module_name_label: Label = $CutsceneUI/Textbox/ModuleName
@onready var module_description_label: Label = $CutsceneUI/Textbox/ModuleDescription
@onready var next_arrow: AnimatedSprite2D = $CutsceneUI/Textbox/NextArrow

# Sound references.
@onready var snd_pickup: AudioStreamPlayer = $CutsceneUI/Sounds/Pickup
@onready var snd_next: AudioStreamPlayer = $CutsceneUI/Sounds/Next

# State variables.
var current_page: int = 0
var input_allowed: bool = false

# Shows the cutscene and plays the pickup sound effect.
func start_cutscene():
	# Assigns the module details.
	module_name_label.text = module_name
	module_description_label.text = module_description
	module_description_label.hide()
	next_arrow.hide()
	
	# Pauses the music.
	MusicManager.pause_music()
	
	# Shows the textbox.
	show()
	get_tree().paused = true
	snd_pickup.play()
	
	# Waits for the sound to finish, then allows input.
	await snd_pickup.finished
	next_arrow.show()
	input_allowed = true

# Checks the input.
func _input(event):
	if input_allowed and event.is_action_pressed("jump"):
		if current_page == 0:
			# Move to the description page.
			snd_next.play()
			module_name_label.hide()
			module_description_label.show()
			current_page += 1
			get_viewport().set_input_as_handled() # Prevent other nodes from receiving this input.
		elif current_page == 1:
			# End the cutscene.
			get_viewport().set_input_as_handled()
			end_cutscene()

# Hides the cutscene and unpauses the game.
func end_cutscene():
	# Immediately block further input.
	input_allowed = false
	Input.action_release("jump")
	
	snd_next.play()
	await snd_next.finished  # Wait for sound to finish.
	
	MusicManager.resume_music()
	hide()
	get_tree().paused = false
	queue_free()
