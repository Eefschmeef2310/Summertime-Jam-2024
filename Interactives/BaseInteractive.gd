extends Control

signal interacted()

func toggle_prompt(toggle:bool):
	visible = toggle

func interact():
	if visible:
		interacted.emit()
