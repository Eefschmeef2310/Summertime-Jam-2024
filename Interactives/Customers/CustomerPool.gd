extends Node

var max_targets: int = 1
var number_of_customers_total = 8

@export var headpieces: Array[CustomerHeadpiece]
@export var skin_colors : Array[Color]
@export var clothes : Array[CustomerClothes]
@export var habit : Array[CustomerHabit]
@export var order_pref : Array[OrderResource]

func get_random_combo() -> CustomerData:
	var data = CustomerData.new()
	data.headpiece = CustomerPool.headpieces.pick_random()
	data.skin_color = CustomerPool.skin_colors.pick_random()
	data.clothing = CustomerPool.clothes.pick_random()
	data.habit = CustomerPool.habit.pick_random()
	data.order_pref = CustomerPool.order_pref.pick_random()
	return data

func get_similarity(a: CustomerData, b: CustomerData) -> int:
	var similarities : int = 0
		
	if a.headpiece == b.headpiece:
		similarities += 1
	if a.skin_color == b.skin_color:
		similarities += 1
	if a.clothing == b.clothing:
		similarities += 1
	if a.habit == b.habit:
		similarities += 1
	if a.order_pref == b.order_pref:
		similarities += 1
		
	return similarities
