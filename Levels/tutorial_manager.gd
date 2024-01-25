extends Node

var customers_spawned : int = 0

func _ready():
	get_tree().paused = true
	$Popup/Label.text = "Welcome to the game! \n WASD to move"
	
func _process(_delta):
	if Input.is_anything_pressed() and !Input.is_action_just_pressed("Pause"):
		get_tree().paused = false

func get_data(customer_timer_control : Control):
	#to force a target, make sure spawn_target_odds only contains a true
	var data = CustomerData.new()
	
	match customers_spawned:
		0:
			$"../TargetManager".spawn_target_odds.clear()
			customer_timer_control.process_mode = Node.PROCESS_MODE_DISABLED
			customer_timer_control.hide()
			data = $"../TargetManager".generate_new_customer_data()
		1:
			$"../TargetManager".spawn_target_odds.clear()
			data = $"../TargetManager".generate_new_customer_data()
		2:
			$"../TargetManager".spawn_target_odds.clear()
			data = $"../TargetManager".generate_new_customer_data()
		3:
			$"../TargetManager".spawn_target_odds.clear()
			$"../TargetManager".spawn_target_odds.append(true)
			data = $"../TargetManager".generate_new_customer_data()
	
	customers_spawned += 1
	
	return data

func phase_complete():
	pass
