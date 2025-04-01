extends Node

# Health signal.
signal on_health_changed

# Weapon switched signal.
signal weapon_switched(weapon_name: String)

# Score signals.
signal score_updated(new_score: int)
signal score_reset()
