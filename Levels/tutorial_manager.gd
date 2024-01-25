extends Node

func _ready():
	get_tree().paused = true
	
func _process(_delta):
	if Input.is_anything_pressed() and !Input.is_action_just_pressed("Pause"):
		get_tree().paused = false
