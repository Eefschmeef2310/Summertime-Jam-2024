extends Control

var enabled = true

signal interacted()

func _process(_delta):
	if !enabled:
		modulate.a = 0
	else:
		modulate.a = 1

func toggle_prompt(toggle:bool):
		visible = toggle

func interact():
	if visible and enabled:
		interacted.emit()
