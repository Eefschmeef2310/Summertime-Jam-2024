extends CharacterBody2D

@export var move_speed: float = 100.0
@export var min_interaction_distance : float = 150

var interactives : Array
var closest_interactive : Node2D

func _ready():
	for i in get_tree().get_nodes_in_group("Interactive"):
		interactives.push_back(i)

func _process(delta):
	var direction = Input.get_vector("Left", "Right", "Up", "Down")
	velocity = direction * move_speed * delta
	move_and_slide()
	
	get_min_distance()
	
	if global_position.distance_to(closest_interactive.global_position) < min_interaction_distance:
		closest_interactive.toggle_prompt(true)
		if Input.is_action_just_pressed("Interact"):
			closest_interactive.interact()
			print("successful interaction")
	else:
		closest_interactive.toggle_prompt(false)
	
func get_min_distance():
	var minimum = interactives[0].global_position.distance_to(global_position)
	var min_index = 0;
	for i in range(1, interactives.size()):
		if interactives[i].global_position.distance_to(global_position) < minimum:
			minimum = interactives[i].global_position.distance_to(global_position)
			min_index = i
	closest_interactive = interactives[min_index]
