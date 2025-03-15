class_name Weapon

var name: String
var projectile_scene: PackedScene
var cooldown: float
var unlocked: bool = false
var icon: Texture2D

func _init(name: String, projectile_scene: PackedScene, cooldown: float, icon: Texture2D = null):
	self.name = name
	self.projectile_scene = projectile_scene
	self.cooldown = cooldown
	self.icon = icon
