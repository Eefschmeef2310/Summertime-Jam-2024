extends CharacterBody2D

@export var move_speed: float = 100
@export var min_interaction_distance : float = 50

@onready var animation_player = $AnimationPlayer

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
	if is_instance_valid(held_item) and Input.is_action_just_pressed("Poison"):
		held_item.poisoned = true
		$Poison.play()
	
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

func set_held_item(item):
	held_item = item
	if !item.get_parent():
		$FoodMarker.add_child(item)
	else:
		item.reparent($FoodMarker)
	held_item.position = Vector2(0, 0)

func handle_animation():
	var direction = Input.get_vector("Left", "Right", "Up", "Down")
	if is_instance_valid(held_item):
		# holding an item
		if direction == Vector2(0, 0):
			animation_player.play("idle_holding")
		else:
			animation_player.play("run_holding")
			if direction.x != 0:
				scale.x = scale.y * sign(direction.x)
	else:
		# not holding an item
		if direction == Vector2(0, 0):
			animation_player.play("idle")
		else:
			animation_player.play("run")
			if direction.x != 0:
				scale.x = scale.y * sign(direction.x)
