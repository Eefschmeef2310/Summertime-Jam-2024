extends Node

var customer_scene: PackedScene = preload("res://customer/customer.tscn")

var target_data: Array[CustomerData]
var targets_that_have_been_spawned: Array[CustomerData]
var spawn_target_odds: Array[bool] = []

var spawn_timer: Timer
var current_spawn_timer
var spawn_timer_decrement = 0.1
var spawn_timer_minimum = 4

var similar_target_buffer

signal targets_created(target_data)
signal target_killed(target)

func _ready():
	generate_target()
	similar_target_buffer = CustomerPool.similar_target_buffer
	
	spawn_timer = $SpawnTimer
	current_spawn_timer = spawn_timer.wait_time

func instantiate_customer():
	# Check if there is at least 1 empty chair
	var chairs = get_tree().get_nodes_in_group("chair")
	var free_chair = false
	for chair in chairs:
		if chair.occupant == null:
			free_chair = true
			break
	
	if free_chair:
		# Spawn customer
		var customer = customer_scene.instantiate()
		if randi_range(0, 1) == 0:
			customer.position.x = 0 - 20
		else:
			customer.position.x = 640 + 20
		get_parent().add_child(customer)
		
	# Start spawn timer
	$SpawnTimer.start()

func generate_new_customer_data() -> CustomerData:
	print("Current target spawn odds: 1 in " + str(spawn_target_odds.size()))
	
	# Decide if this customer should be a target or not
	var spawn_target = false
	if !spawn_target_odds.is_empty():
		var rand = randi_range(0, spawn_target_odds.size()-1)
		spawn_target = spawn_target_odds[rand]
		spawn_target_odds.remove_at(rand)
	
	if spawn_target == true:
		# Create target that hasn't been spawned yet
		print("Generating TARGET")
		var data: CustomerData = target_data.pick_random()
		while data in targets_that_have_been_spawned:
			data = target_data.pick_random()
		targets_that_have_been_spawned.append(data)
		spawn_target_odds.clear()
		return data
	
	else:
		# Create regular customer
		# Make sure they do not match target exactly
		print("Generating")
		var data: CustomerData
		var unique = false
		
		# Similarity functionality to make some customers similar to a target
		var similar_to_target = false
		if similar_target_buffer > 0:
			similar_target_buffer -= 1
		else:
			similar_to_target = (randi_range(1, CustomerPool.chance_of_similar_to_target) == 1)
		
		while !unique:
			data = CustomerPool.get_random_combo()
			if similar_to_target and !target_data.is_empty():
				data.headpiece = target_data[0].headpiece
				data.clothing = target_data[0].clothing
				similar_target_buffer = CustomerPool.similar_target_buffer
				print("THIS CUSTOMER IS SIMILAR TO THE TARGET!!")
			unique = true
			for target in target_data:
				if CustomerPool.get_similarity(data, target) >= 4:
					unique = false
		return data

func generate_target():
	targets_that_have_been_spawned.clear()
	
	# Generate target data
	for i in CustomerPool.max_targets:
		var data: CustomerData
		var unique = false
		while !unique:
			data = CustomerPool.get_random_combo()
			unique = true
			for target in target_data:
				if CustomerPool.get_similarity(data, target) >= 5:
					unique = false
		data.is_target = true
		target_data.append(data)
	
	# Create random spawn map
	spawn_target_odds.resize(CustomerPool.chance_of_target)
	spawn_target_odds.fill(false)
	for n in CustomerPool.max_targets:
		if n < spawn_target_odds.size():
			spawn_target_odds[n] = true
	
	print(target_data)
	targets_created.emit(target_data)

func customer_killed(data: CustomerData):
	if data.is_target:
		# Was a target.
		ScoreManager.score += 10
		target_killed.emit(data)
		target_data.erase(data)
		generate_target()
	else:
		# Was not a target.
		GameOverManager.game_over("You eliminated an innocent person!")
			

#func _ready():
	#target = get_tree().get_nodes_in_group("Customer").pick_random()
	#
	#if target:
		#target.initialise()
	#
	#for i in get_tree().get_nodes_in_group("Customer"):
		#if i != target:
			#i.target_manager = self
			#print(i.target_manager)
			#i.initialise()


func _on_startup_timer_timeout():
	instantiate_customer()


func _on_spawn_timer_timeout():
	instantiate_customer()
	
	# Make timer shorter next time
	current_spawn_timer -= spawn_timer_decrement
	spawn_timer.wait_time = current_spawn_timer
	spawn_timer.start()
	
	print("Spawn Timer is now at " + str(current_spawn_timer) + " seconds.")
