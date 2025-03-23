extends Node

# Music player reference.
var music_player: AudioStreamPlayer = null

# Current music stream.
var current_music: AudioStream = null

# Plays music with a specified volume.
func play_music(music: AudioStream, volume_db: float = 0.0):
	# Stop any existing music.
	if music_player:
		stop_music()

	# Create and configure the new music player.
	current_music = music
	music_player = AudioStreamPlayer.new()
	music_player.stream = current_music
	music_player.volume_db = volume_db  # Set the volume
	add_child(music_player)
	music_player.play()

# Sets the volume of the current music.
func set_volume(volume_db: float):
	if music_player:
		music_player.volume_db = volume_db

# Pauses the current music.
func pause_music():
	if music_player:
		music_player.stream_paused = true

# Resumes the current music.
func resume_music():
	if music_player:
		music_player.stream_paused = false

# Stops the current music.
func stop_music():
	if music_player:
		music_player.stop()
		music_player.queue_free()
		music_player = null
