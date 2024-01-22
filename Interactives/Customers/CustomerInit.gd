extends Node

var target_manager

var complete: bool = false

var headpiece
var skin_color
var clothing
var habit
var order_pref

func initialise():
	#Random shuffle if target manager is null (if !target_manager, then node is target)
	#Every time shuffle occurs, if target_manager, check random attributes against target. reshuffle accordingly
	
	generate_attributes()
	
	while target_manager and !complete:
		generate_attributes()
	
func generate_attributes():
	headpiece = CustomerPool.headpieces.pick_random()
	skin_color = CustomerPool.skin_colors.pick_random()
	clothing = CustomerPool.clothes.pick_random()
	habit = CustomerPool.habit.pick_random()
	order_pref = CustomerPool.order_pref.pick_random()
	
	if target_manager:
		var differences := 0
		
		if headpiece == target_manager.target.headpiece:
			differences += 1
		if skin_color == target_manager.target.skin_color:
			differences += 1
		if clothing == target_manager.target.clothing:
			differences += 1
		if habit == target_manager.target.habit:
			differences += 1
		if order_pref == target_manager.target.order_pref:
			differences += 1
			
		complete = differences > 3
	
