extends Control

# Module variables.
var module_name: String = "Module Name"
var module_description: String = "Module Description"

# References to UI elements.
@onready var module_name_label: Label = $Textbox/ModuleNameLabel
@onready var module_description_label: Label = $Textbox/ModuleDescriptionLabel
@onready var snd_pickup: AudioStreamPlayer = $Sounds/Pickup

# State variables.
var current_page: int = 0
var input_allowed: bool = false

# Shows the cutscene and plays the pickup sound effect.
func start_cutscene():
	# Assigns the module details.
	module_name_label.text = module_name
	module_description_label.text = module_description
	module_description_label.hide()
	
	# Pauses the music.
	MusicManager.pause_music()
	
	# Shows the textbox.
	show()
	get_tree().paused = true
	snd_pickup.play()
	
	# Waits for the sound to finish, then allows input.
	await snd_pickup.finished
	input_allowed = true

# Checks the input.
func _input(event):
	if input_allowed and event.is_action_pressed("jump") and is_visible_in_tree():
		if current_page == 0:
			# Move to the description page.
			module_name_label.hide()
			module_description_label.show()
			current_page += 1
		elif current_page == 1:
			# End the cutscene.
			end_cutscene()

# Hides the cutscene and unpauses the game.
func end_cutscene():
	MusicManager.resume_music()
	hide()
	get_tree().paused = false
	queue_free()
