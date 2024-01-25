extends Control

var reason : String

func _ready():
	get_tree().paused = true
	$MarginContainer/VBoxContainer/ReasonOfDeath.text = reason

func _on_menu_button_pressed():
	get_tree().paused = false
	queue_free()
	get_tree().change_scene_to_file("res://Levels/menus/MainMenu.tscn")
