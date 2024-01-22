extends Node2D

signal interacted()

func toggle_prompt(toggle:bool):
	$InteractivePrompt.visible = toggle

func interact():
	if visible:
		interacted.emit()
