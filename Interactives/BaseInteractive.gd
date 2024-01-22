extends StaticBody2D

signal interacted()

func toggle_prompt(toggle:bool):
	$InteractivePrompt.visible = toggle

func interact():
	interacted.emit()
