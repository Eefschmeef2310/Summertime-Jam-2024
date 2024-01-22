extends CharacterBody2D

@export var move_speed: float = 20000
@export var min_interaction_distance : float = 50

var interactives : Array
var closest_interactive : Node2D

func _ready():
	pass

func _process(delta):
	var direction = Input.get_vector("Left", "Right", "Up", "Down")
	velocity = direction * move_speed * delta
	move_and_slide()
	
	get_closest_interactable()
	
	if is_instance_valid(closest_interactive):
		if global_position.distance_to(closest_interactive.global_position) < min_interaction_distance and closest_interactive.visible:
			closest_interactive.toggle_prompt(true)
			if Input.is_action_just_pressed("Interact"):
				closest_interactive.interact()
				print("successful interaction")
		else:
			closest_interactive.toggle_prompt(false)
	else:
		closest_interactive = null
	
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
