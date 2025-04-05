extends Resource
class_name PlayerSaveData

@export var player_position: Vector2 = Vector2.ZERO
@export var current_health: int = 3
@export var max_health: int = 3
@export var unlocked_weapons: Array[String] = []
@export var current_weapon: String = ""
@export var scene_path: String = ""
