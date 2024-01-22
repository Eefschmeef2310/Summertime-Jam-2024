extends Node

var target

func _ready():
	target = get_tree().get_nodes_in_group("Customer").pick_random()
	
	if target:
		target.initialise()
	
	for i in get_tree().get_nodes_in_group("Customer"):
		if i != target:
			i.target_manager = self
			i.initialise()
