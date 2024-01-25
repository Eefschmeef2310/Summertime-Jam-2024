extends Node

const PAUSE = preload("res://Levels/menus/pause.tscn")

func _process(delta):
	if Input.is_action_just_pressed("Pause") and !get_tree().get_first_node_in_group("pause_screen"):
		get_tree().root.add_child(PAUSE.instantiate())
