extends Control

var options_instantiated

var options : PackedScene = preload("res://Levels/menus/options.tscn")

func _ready():
	get_tree().paused = true
	
func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		_on_continue_pressed()

func _on_continue_pressed():
	if options_instantiated:
		options_instantiated.queue_free()
	
	get_tree().paused = false
	queue_free()

func _on_menu_button_pressed():
	get_tree().paused = false
	queue_free()
	get_tree().change_scene_to_file("res://Levels/MainMenu.tscn")

func _on_options_pressed():
	options_instantiated = options.instantiate()
	get_tree().root.add_child(options_instantiated)
