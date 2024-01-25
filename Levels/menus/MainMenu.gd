extends Control

const OPTIONS = preload("res://Levels/menus/options.tscn")
const CREDITS = preload("res://Levels/menus/credits.tscn")
const LEADERBOARD = preload("res://Levels/menus/Leaderboard.tscn")

func _ready():
	get_tree().paused = false
	$MarginContainer/HBoxContainer/Leftside/QuitButton.visible = OS.get_name() != "Web"

func _on_start_button_pressed():
	ScoreManager.playtime = 0
	ScoreManager.score = 0
	get_tree().change_scene_to_file("res://Levels/level.tscn")

func _on_tutorial_button_pressed():
	get_tree().change_scene_to_file("res://Levels/tutorial.tscn")

func _on_leaderboard_button_pressed():
	get_tree().root.add_child(LEADERBOARD.instantiate())

func _on_options_button_pressed():
	get_tree().root.add_child(OPTIONS.instantiate())

func _on_quit_button_pressed():
	get_tree().quit()

func _on_logout_button_pressed():
	get_tree().change_scene_to_file(AirtableManager.usernamePickerScene)

func _on_credits_button_pressed():
	get_tree().root.add_child(CREDITS.instantiate())
