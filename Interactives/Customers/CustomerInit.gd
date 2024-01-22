extends Node

var target_manager

var headpiece
var skin_color
var clothing
var habit
var order_pref

func initialise():
	#Random shuffle if target manager is null (if !target_manager, then node is target)
	#Every time shuffle occurs, if target_manager, check random attributes against target. reshuffle accordingly
	
	headpiece = CustomerPool.headpieces.pick_random()
	skin_color = CustomerPool.skin_colors.pick_random()
	clothing = CustomerPool.clothes.pick_random()
	habit = CustomerPool.habit.pick_random()
	order_pref = CustomerPool.order_prefs.pick_random()
