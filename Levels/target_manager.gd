extends Node

var target_data: Array[CustomerData]
var targets_that_have_been_spawned: Array[CustomerData]
var spawn_target_odds: Array[bool] = []

func _ready():
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
	spawn_target_odds.resize(CustomerPool.number_of_customers_total)
	spawn_target_odds.fill(false)
	for n in CustomerPool.max_targets:
		if n < spawn_target_odds.size():
			spawn_target_odds[n] = true

func generate_new_customer() -> CustomerData:
	# Decide if this customer should be a target or not
	var rand = randi_range(0, spawn_target_odds.size()-1)
	var spawn_target = spawn_target_odds[rand]
	spawn_target_odds.remove_at(rand)
	
	if spawn_target == true:
		# Create target that hasn't been spawned yet
		print("Generating TARGET")
		var data: CustomerData = target_data.pick_random()
		while data in targets_that_have_been_spawned:
			data = target_data.pick_random()
		targets_that_have_been_spawned.append(data)
		return data
	
	else:
		# Create regular customer
		# Make sure they do not match target exactly
		# TODO: implement similarity functionality to make some customers similar to a target
		print("Generating")
		var data: CustomerData
		var unique = false
		while !unique:
			data = CustomerPool.get_random_combo()
			unique = true
			for target in target_data:
				if CustomerPool.get_similarity(data, target) >= 5:
					unique = false
		return data

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
