extends Node

var game_over_screen : PackedScene = preload("res://Levels/menus/game_over_screen.tscn")

func game_over(reason : String):
	AirtableManager.GameComplete(ScoreManager.score, ScoreManager.playtime)
	var game_over = game_over_screen.instantiate()
	game_over.reason = reason
	get_tree().root.add_child(game_over)
