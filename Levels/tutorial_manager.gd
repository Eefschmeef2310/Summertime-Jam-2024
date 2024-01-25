extends Node

var customers_spawned : int = 0
var phase = 0
var poison_available: bool = false

func _ready():
	$Popup/Label.text = "Welcome to the game! \n WASD to move"
	
func _process(_delta):
	if Input.is_action_just_pressed("Poison") and phase == 7:
		phase_complete()

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
	match phase:
		0:
			$Popup/Label.text = "Press Space or E to pick up what someone wants, \nthen cook, then serve!"
		1: #First customer fed
			$Popup/Label.text = "If you served someone correctly, \nyour score will increase! ->"
		2: #First customer off-screen
			$"../TargetManager".instantiate_customer()
		3: #Second customer sat down
			$Popup/Label.text = "People have timers on their orders. \nIf any timers run out, it's Game Over!"
		4: #Second customer fed
			$Popup/Label.text = "Good job!"
		5: #Second customer off screen
			$"../TargetManager".instantiate_customer()
			$"../TargetManager".instantiate_customer()
		6: #First customer sits
			pass
		7: #second customer sits
			$Popup/Label.text = "Some people will be targets for you to eliminate.\nPress Q to poison the target's food, then cook and serve!"
			poison_available = true
		8: #First poision
			$Popup/Label.text = "Be careful! If a non-target is eliminated,\nor a target is left alive, it's Game Over (again)!"
		9: #First customer leaves
			pass
		10: #Second customer leaves
			$Popup/Label.text = "Tutorial complete! Make a complete screen"	
	
	phase += 1
