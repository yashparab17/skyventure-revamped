extends Node

################################################################################
# SIGNALS
################################################################################

# Health signals.
signal health_changed(new_health)
signal max_health_changed(new_max_health)
signal player_died

# Score signals.
signal score_changed(new_score)
signal score_reset()

# Weapon signals.
signal weapon_changed(new_weapon)
signal weapon_unlocked(weapon_name)

# Player signals.
signal player_position_updated(new_position)

# Booster signals.
signal booster_unlocked
signal booster_activated
signal booster_ended

################################################################################
# CONSTANTS
################################################################################

const DEFAULT_MAX_HEALTH := 3
const DEFAULT_SCORE := 0

################################################################################
# PROPERTIES
################################################################################

# Health properties.
var max_health := DEFAULT_MAX_HEALTH:
	set(value):
		max_health = max(1, value)
		emit_signal("max_health_changed", max_health)
		# Ensure current health doesn't exceed new max
		if current_health > max_health:
			current_health = max_health
			emit_signal("health_changed", current_health)

var current_health := DEFAULT_MAX_HEALTH:
	set(value):
		var new_value = clamp(value, 0, max_health)
		if new_value != current_health:
			current_health = new_value
			emit_signal("health_changed", current_health)
			if current_health <= 0:
				emit_signal("player_died")

# Score property.
var score := DEFAULT_SCORE:
	set(value):
		score = max(0, value)
		emit_signal("score_changed", score)

# Player position.
var pending_player_position: Vector2 = Vector2.INF:
	set(value):
		pending_player_position = value
		if value != Vector2.INF:
			emit_signal("player_position_updated", value)

# Weapon system.
var weapons: Array[Weapon] = [
	Weapon.new("Star Bullet", preload("res://scenes/projectiles/star_bullet.tscn"), 0.25),
	Weapon.new("Fireball", preload("res://scenes/projectiles/fireball.tscn"), 0.8),
	Weapon.new("Leaf Blower", preload("res://scenes/projectiles/leaf_projectile.tscn"), 0.15),
	Weapon.new("Water Missile", preload("res://scenes/projectiles/water_missile.tscn"), 1.0),
]

var current_weapon_index: int = -1:
	set(value):
		if value >= -1 and value < weapons.size() and (value == -1 or weapons[value].unlocked):
			current_weapon_index = value
			if current_weapon_index != -1:
				current_weapon_name = weapons[current_weapon_index].name
			else:
				current_weapon_name = ""

var current_weapon_name := "":
	set(value):
		if value != current_weapon_name:
			current_weapon_name = value
			emit_signal("weapon_changed", current_weapon_name)

# Booster system.
var has_booster_unlocked: bool = false:
	set(value):
		has_booster_unlocked = value
		emit_signal("booster_unlocked") # You'll need to add this signal

var has_boost_available: bool = true
var booster_active: bool = false
var boost_cooldown_timer: float = 0.0
var boost_cooldown: float = 1.0

# Player reference.
var player_is_on_floor: bool = false
var player_node: CharacterBody2D = null

# Spawn system.
var pending_spawn_data := {
	"scene": "",
	"spawn_id": ""
}

# Save system.
var pending_save_data: Dictionary = {}

# Cutscene system.
var triggered_cutscenes: Dictionary = {}

# Module system.
var collected_modules: Dictionary = {}

func has_collected_module(module_id: String) -> bool:
	return collected_modules.get(module_id, false)

func mark_module_as_collected(module_id: String) -> void:
	collected_modules[module_id] = true

################################################################################
# PUBLIC METHODS - HEALTH
################################################################################

func decrease_health(amount: int) -> void:
	current_health -= amount

func increase_health(amount: int) -> void:
	current_health += amount

func reset_health() -> void:
	current_health = max_health

func increase_max_health(amount: int) -> void:
	max_health += amount

################################################################################
# PUBLIC METHODS - SCORE
################################################################################

func increment_score(amount: int) -> void:
	score += amount

func reset_score() -> void:
	score = DEFAULT_SCORE
	emit_signal("score_reset")

################################################################################
# PUBLIC METHODS - WEAPONS
################################################################################

func unlock_weapon(weapon_name: String) -> bool:
	for i in weapons.size():
		if weapons[i].name == weapon_name:
			if not weapons[i].unlocked:
				weapons[i].unlocked = true
				emit_signal("weapon_unlocked", weapon_name)
				
				# Auto-equip first unlocked weapon
				if current_weapon_index == -1:
					switch_weapon(i)
				return true
			return false
	return false

func switch_weapon(index: int) -> void:
	current_weapon_index = index

func switch_to_next_weapon() -> void:
	if current_weapon_index == -1: return
	
	for i in range(1, weapons.size()):
		var next_index = (current_weapon_index + i) % weapons.size()
		if weapons[next_index].unlocked:
			switch_weapon(next_index)
			break

func switch_to_previous_weapon() -> void:
	if current_weapon_index == -1: return
	
	for i in range(1, weapons.size()):
		var prev_index = (current_weapon_index - i + weapons.size()) % weapons.size()
		if weapons[prev_index].unlocked:
			switch_weapon(prev_index)
			break

func has_weapon(name: String) -> bool:
	for weapon in weapons:
		if weapon.name.to_lower() == name.to_lower() and weapon.unlocked:
			return true
	return false

func get_current_weapon() -> Weapon:
	if current_weapon_index >= 0 and current_weapon_index < weapons.size():
		return weapons[current_weapon_index]
	return null

func get_unlocked_weapon_names() -> PackedStringArray:
	var unlocked_names = PackedStringArray()
	for weapon in weapons:
		if weapon.unlocked:
			unlocked_names.append(weapon.name)
	return unlocked_names

################################################################################
# PUBLIC METHODS - BOOSTER MODULE
################################################################################

func register_player(player: CharacterBody2D) -> void:
	player_node = player

func unlock_booster() -> void:
	if not has_booster_unlocked:
		has_booster_unlocked = true
		emit_signal("booster_unlocked")

func is_booster_available() -> bool:
	return has_booster_unlocked and has_boost_available and not player_is_on_floor

func update_boost_timers(delta: float) -> void:
	if boost_cooldown_timer > 0:
		boost_cooldown_timer -= delta
	# Reset cooldown when landing
	if player_is_on_floor:
		has_boost_available = true
		boost_cooldown_timer = 0

func start_boost() -> void:
	if is_booster_available():
		booster_active = true
		has_boost_available = false
		boost_cooldown_timer = boost_cooldown
		emit_signal("booster_activated")

func end_boost() -> void:
	if booster_active:
		booster_active = false
		emit_signal("booster_ended")

func reset_booster() -> void:
	has_booster_unlocked = false
	booster_active = false
	boost_cooldown_timer = 0.0

################################################################################
# PUBLIC METHODS - SPAWN SYSTEM
################################################################################

func set_pending_spawn(scene: String, spawn_id: String) -> void:
	pending_spawn_data["scene"] = scene
	pending_spawn_data["spawn_id"] = spawn_id

func consume_pending_spawn_id() -> String:
	var id = pending_spawn_data["spawn_id"]
	pending_spawn_data["spawn_id"] = ""
	return id

################################################################################
# PUBLIC METHODS - CUTSCENE SYSTEM
################################################################################

func has_seen_cutscene(cutscene_id: String) -> bool:
	return triggered_cutscenes.get(cutscene_id, false)

func mark_cutscene_as_seen(cutscene_id: String) -> void:
	triggered_cutscenes[cutscene_id] = true

################################################################################
# PUBLIC METHODS - GAME STATE
################################################################################

func reset_game_state() -> void:
	reset_health()
	reset_score()
	current_weapon_index = -1
	
	# Reset weapon unlocks but keep the definitions.
	for weapon in weapons:
		weapon.unlocked = false
	
	reset_booster()
	
	# Clear pending position and save.
	pending_player_position = Vector2.INF
	pending_save_data = {}

	# Clear triggered cutscenes.
	triggered_cutscenes.clear()
