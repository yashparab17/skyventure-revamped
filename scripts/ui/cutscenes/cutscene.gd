extends CanvasLayer

class_name CutsceneSystem

# Node references.
@onready var portrait: TextureRect = $CutsceneUI/Portrait
@onready var textbox: TextureRect = $CutsceneUI/Textbox
@onready var name_label: Label = $CutsceneUI/Textbox/Name
@onready var text_label: Label = $CutsceneUI/Textbox/Text
@onready var next_arrow: AnimatedSprite2D = $CutsceneUI/Textbox/NextArrow

# Sound references.
@onready var snd_next: AudioStreamPlayer = $CutsceneUI/Sounds/Next

# State variables.
var current_page: int = 0
var input_allowed: bool = false
var pages: Array = []
var end_callback: Callable = Callable()

func _ready():
	# Hide everything initially.
	hide()
	portrait.hide()
	name_label.hide()
	text_label.hide()
	next_arrow.hide()

# Starts a new cutscene with the given pages.
func start_cutscene(cutscene_pages: Array, callback: Callable = Callable()):
	if cutscene_pages.is_empty():
		push_error("No pages provided for cutscene")
		return
	
	pages = cutscene_pages
	end_callback = callback
	current_page = 0
	
	# Pause the game.
	get_tree().paused = true
	
	# Show the UI and first page.
	show()
	_display_page(current_page)
	
	await get_tree().create_timer(0.5).timeout
	
	input_allowed = true
	next_arrow.show()

# Displays a specific page.
func _display_page(page_index: int):
	if page_index >= pages.size():
		return
	
	var page = pages[page_index]
	
	# Set portrait if available.
	if page.has("portrait"):
		portrait.texture = page["portrait"]
		portrait.show()
	else:
		portrait.hide()
	
	# Set name if available.
	if page.has("name"):
		name_label.text = page["name"]
		name_label.show()
	else:
		name_label.hide()
	
	# Set text (required).
	if page.has("text"):
		text_label.text = page["text"]
		text_label.show()
	else:
		push_error("Cutscene page missing text")
		text_label.hide()

# Handles input.
func _input(event):
	if not input_allowed or not event.is_action_pressed("jump"):
		return
	
	current_page += 1
	
	if current_page < pages.size():
		# Show next page.
		next_arrow.hide()
		input_allowed = false
		_display_page(current_page)
		
		snd_next.play()

		await snd_next.finished
		
		input_allowed = true
		next_arrow.show()
	else:
		end_cutscene()

# Ends the current cutscene.
func end_cutscene():
	# Immediately block further input.
	input_allowed = false
	Input.action_release("jump")

	snd_next.play()
	await snd_next.finished # Wait for sound to finish.

	hide()
	get_tree().paused = false

	if end_callback.is_valid():
		end_callback.call()

	queue_free()
