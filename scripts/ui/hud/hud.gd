extends CanvasLayer

@onready var health_display = $HealthDisplay
@onready var weapon_display = $WeaponDisplay
@onready var score_display = $ScoreDisplay

func _ready():
	# Connect to GameState signals.
	GameState.health_changed.connect(_on_health_changed)
	GameState.score_changed.connect(_on_score_changed)
	GameState.weapon_changed.connect(_on_weapon_changed)
	
	# Initialize with current values.
	_on_health_changed(GameState.current_health)
	_on_score_changed(GameState.score)
	_on_weapon_changed(GameState.current_weapon)

func _on_health_changed(new_health: int):
	health_display.update_health(new_health)

func _on_score_changed(new_score: int):
	score_display.update_score(new_score)

func _on_weapon_changed(new_weapon: String):
	weapon_display.update_weapon(new_weapon)
