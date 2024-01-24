extends Control

func _ready():
	$HBoxContainer/Leftside/QuitButton.visible = OS.get_name() != "Web"

func _on_start_button_pressed():
	print("Scene Changed")

func _on_tutorial_button_pressed():
	print("Tutorial Loaded")

func _on_leaderboard_button_pressed():
	print("Leaderboard Loaded")

func _on_options_button_pressed():
	print("Options Loaded")

func _on_quit_button_pressed():
	get_tree().quit()


func _on_logout_button_pressed():
	get_tree().change_scene_to_file(AirtableManager.usernamePickerScene)
