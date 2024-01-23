extends Node2D

var player

var left_item : Node2D
var middle_item : Node2D
var right_item : Node2D

func _ready():
	player = get_tree().get_first_node_in_group("Player")

func _on_left_prompt_interacted():
	if !left_item:
		left_item = player.held_item
		player.held_item.reparent(self)
		player.held_item = null
		left_item.global_position = $LeftPrompt/FoodMarker.global_position
		left_item.start_cook_timer()
	else:
		return_to_player(left_item)
		left_item = null

func _on_middle_prompt_interacted():
	if !middle_item:
		middle_item = player.held_item
		player.held_item.reparent(self)
		player.held_item = null
		middle_item.global_position = $MiddlePrompt/FoodMarker.global_position
		middle_item.start_cook_timer()
	else:
		return_to_player(middle_item)
		middle_item = null

func _on_right_prompt_interacted():
	if !right_item:
		right_item = player.held_item
		player.held_item.reparent(self)
		player.held_item = null
		right_item.global_position = $RightPrompt/FoodMarker.global_position
		right_item.start_cook_timer()
	else:
		return_to_player(right_item)
		right_item = null
	
func return_to_player(item):
	player.held_item = item
	item.reparent(player)
