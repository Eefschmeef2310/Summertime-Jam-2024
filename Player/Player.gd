extends CharacterBody2D

@export var move_speed: float = 100
@export var min_interaction_distance : float = 50

var interactives : Array
var closest_interactive : Control

var held_item: HoldableItemScene

func _process(_delta):
	var direction = Input.get_vector("Left", "Right", "Up", "Down")
	velocity = direction * move_speed
	move_and_slide()
	
	get_closest_interactable()
	
	if is_instance_valid(closest_interactive):
		if global_position.distance_to(closest_interactive.global_position) < min_interaction_distance:
			closest_interactive.toggle_prompt(true)
			if Input.is_action_just_pressed("Interact"):
				closest_interactive.interact()
		else:
			closest_interactive.toggle_prompt(false)
	else:
		closest_interactive = null
	
	# TODO PLACEHOLDER FOR DEBUG
	if held_item and Input.is_action_just_pressed("Poison"):
		held_item.poisoned = true
	
	handle_animation()
	
func get_closest_interactable():
	#Also turns off prompts lol - E
	var interactives = get_tree().get_nodes_in_group("Interactive")
	if interactives:
		var minimum = interactives[0].global_position.distance_to(global_position)
		var min_index = 0;
		interactives[0].toggle_prompt(false)
		for i in range(1, interactives.size()):
			interactives[i].toggle_prompt(false)
			if interactives[i].global_position.distance_to(global_position) < minimum:
				minimum = interactives[i].global_position.distance_to(global_position)
				min_index = i
		closest_interactive = interactives[min_index]

func handle_animation():
	var direction = Input.get_vector("Left", "Right", "Up", "Down")
	pass
