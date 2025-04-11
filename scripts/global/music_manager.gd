extends Node

# Music player reference.
var music_player: AudioStreamPlayer = null

# Current music stream.
var current_music: AudioStream = null

# Constant values.
const DEFAULT_VOLUME_DB := 0.0
const DIMMED_VOLUME_DB := -10.0

# Boolean values for dimming and pausing.
var is_dimmed: bool = false
var is_paused: bool = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

# Plays music with a specified volume.
func play_music(music: AudioStream, volume_db: float = DEFAULT_VOLUME_DB):
	# Stop any existing music.
	if music_player:
		stop_music()

	# Create and configure the new music player.
	current_music = music
	
	# Loop the music.
	if current_music is AudioStream:
		current_music.loop = true
	
	music_player = AudioStreamPlayer.new()
	music_player.stream = current_music
	music_player.volume_db = volume_db
	add_child(music_player)
	music_player.play()

# Sets the volume of the current music.
func set_volume(volume_db: float):
	if music_player:
		music_player.volume_db = volume_db

# Temporarily dim the music (for pause screens or cutscenes).
func dim_music():
	if music_player and not is_paused:
		music_player.volume_db = DIMMED_VOLUME_DB
		is_dimmed = true

# Restore music to full volume.
func undim_music():
	if music_player and not is_paused:
		music_player.volume_db = DEFAULT_VOLUME_DB
		is_dimmed = false

# Fully pause music (e.g. for jingles).
func pause_music():
	if music_player:
		music_player.stream_paused = true
		is_paused = true

# Fully resume music.
func resume_music():
	if music_player:
		music_player.stream_paused = false
		is_paused = false
		# Restore dimmed state if needed.
		music_player.volume_db = DIMMED_VOLUME_DB if is_dimmed else DEFAULT_VOLUME_DB

# Stops the current music.
func stop_music():
	if music_player:
		music_player.stop()
		music_player.queue_free()
		music_player = null

func is_playing() -> bool:
	return music_player != null and music_player.playing

func is_current_music(music: AudioStream) -> bool:
	return current_music == music
