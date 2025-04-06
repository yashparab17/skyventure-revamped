extends Resource
class_name SaveGame

@export var scene_path: String = ""
@export var player_position: Vector2 = Vector2.ZERO
@export var player_health: int = 3
@export var unlocked_weapons: PackedStringArray = []
@export var current_weapon: String = ""
@export var score: int = 0
