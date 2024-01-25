extends Node2D

var player

var left_item : HoldableItemScene
var middle_item : HoldableItemScene
var right_item : HoldableItemScene

func _ready():
	player = get_tree().get_first_node_in_group("Player")
	
func _process(delta):
	if (left_item or middle_item or right_item) and !$Sizzler.playing:
		$Sizzler.play()
	elif (!left_item and !middle_item and !right_item):
		$Sizzler.stop()
		
	$LeftPrompt/Label.text = "Collect" if (left_item and left_item.cooked) else "Cook"

func _on_left_prompt_interacted():
	#uncooked placement
	if !left_item and is_instance_valid(player.held_item):
		left_item = player.held_item
		player.held_item.reparent(self)
		player.held_item = null
		left_item.global_position = $LeftPrompt/FoodMarker.global_position
		left_item.scale = Vector2(1, 1)
		left_item.rotation = 0
		if !left_item.cooked:
			left_item.start_cook_timer()
	elif left_item and left_item.cooked and !is_instance_valid(player.held_item):
		return_to_player(left_item)
		left_item = null

func _on_middle_prompt_interacted():
	if !middle_item and is_instance_valid(player.held_item):
		middle_item = player.held_item
		player.held_item.reparent(self)
		player.held_item = null
		middle_item.global_position = $MiddlePrompt/FoodMarker.global_position
		middle_item.scale = Vector2(1, 1)
		middle_item.rotation = 0
		if !middle_item.cooked:
			middle_item.start_cook_timer()
	elif middle_item and middle_item.cooked and !is_instance_valid(player.held_item):
		return_to_player(middle_item)
		middle_item = null

func _on_right_prompt_interacted():
	if !right_item and is_instance_valid(player.held_item):
		right_item = player.held_item
		player.held_item.reparent(self)
		player.held_item = null
		right_item.global_position = $RightPrompt/FoodMarker.global_position
		right_item.scale = Vector2(1, 1)
		right_item.rotation = 0
		if !right_item.cooked:
			right_item.start_cook_timer()
	elif right_item and right_item.cooked and !is_instance_valid(player.held_item):
		return_to_player(right_item)
		right_item = null
	
func return_to_player(item):
	player.set_held_item(item)
