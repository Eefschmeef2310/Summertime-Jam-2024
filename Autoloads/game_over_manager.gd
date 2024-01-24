extends Node

var game_over_screen : PackedScene = preload("res://Levels/menus/game_over_screen.tscn")

func game_over():
	get_tree().root.add_child(game_over_screen.instantiate())
