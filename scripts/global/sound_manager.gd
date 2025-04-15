extends Node

# Max audio streams.
const MAX_PLAYERS = 10

# Arrays to hold global AudioStreamPlayers and positional AudioStreamPlayer2Ds.
var global_players: Array[AudioStreamPlayer] = []
var positional_players: Array[AudioStreamPlayer2D] = []

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Create global AudioStreamPlayers.
	for i in MAX_PLAYERS:
		var player = AudioStreamPlayer.new()
		add_child(player)
		global_players.append(player)

	# Create positional AudioStreamPlayer2Ds.
	for i in MAX_PLAYERS:
		var player2d = AudioStreamPlayer2D.new()
		add_child(player2d)
		positional_players.append(player2d)

func play_sound(stream: AudioStream, volume_db: float = 0.0):
	for player in global_players:
		if not player.playing:
			player.stream = stream
			player.pitch_scale = randf_range(0.9, 1.1)
			player.volume_db = volume_db
			player.play()
			return player

	global_players[0].stop()
	global_players[0].stream = stream
	global_players[0].pitch_scale = randf_range(0.9, 1.1)
	global_players[0].volume_db = volume_db
	global_players[0].play()
	return global_players[0]

func play_sound_2d(stream: AudioStream, position: Vector2, volume_db: float = 0.0):
	for player in positional_players:
		if not player.playing:
			player.global_position = position
			player.stream = stream
			player.pitch_scale = randf_range(0.9, 1.1)
			player.volume_db = volume_db
			player.play()
			return player

	positional_players[0].stop()
	positional_players[0].global_position = position
	positional_players[0].stream = stream
	positional_players[0].pitch_scale = randf_range(0.9, 1.1)
	positional_players[0].volume_db = volume_db
	positional_players[0].play()
	return positional_players[0]
