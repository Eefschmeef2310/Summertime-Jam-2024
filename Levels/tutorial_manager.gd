extends Node

func _ready():
	get_tree().paused = true
	$Popup/Label.text = "Welcome to the game! \n WASD to move"
	
func _process(_delta):
	if Input.is_anything_pressed() and !Input.is_action_just_pressed("Pause"):
		get_tree().paused = false
