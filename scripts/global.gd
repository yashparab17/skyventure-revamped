extends Node

var hud: CanvasLayer = null

func show_hud() -> void:
	if hud:
		hud.visible = true

func hide_hud() -> void:
	if hud:
		hud.visible = false
