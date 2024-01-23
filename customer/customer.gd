extends Node2D

var state = "entering"

var target_chair = null
var just_interacted_with = false

var move_speed = 75

@export var animation_players: Array[AnimationPlayer]

func _process(delta):
	match state:
		"entering":
			state_entering(delta)
		"waiting_order":
			state_waiting_order()
		"waiting_food":
			state_waiting_food()
		"exiting":
			state_exiting(delta)

func play_animation(s):
	for ap in animation_players:
		ap.play(s)

func state_entering(delta):
	play_animation("walk")
	if !target_chair:
		var chairs = get_tree().get_nodes_in_group("chair")
		for chair in chairs:
			if !chair.occupant != null:
				chair.occupant = self
				target_chair = chair
				position.y = target_chair.position.y + 5
				break
	else:
		position = position.move_toward(target_chair.position, move_speed * delta)
		position.y = target_chair.position.y + 5
		scale.x = -1 * sign(position.x - target_chair.scale.x)
		if position.distance_to(target_chair.position) <= 6:
			#sit down
			state = "waiting_order"

func state_waiting_order():
	position = target_chair.position
	scale.x = target_chair.scale.x
	play_animation("sit")
	
	#$InteractivePrompt.show()
	if just_interacted_with:
		print("Thanks for taking my order!")
		just_interacted_with = false
		state = "waiting_food"

func state_waiting_food():
	position = target_chair.position
	scale.x = target_chair.scale.x
	play_animation("sit")
	
	#$InteractivePrompt.show()
	if just_interacted_with:
		print("Thanks for the food!")
		just_interacted_with = false
		state = "exiting"

func state_exiting(delta):
	play_animation("walk")
	if target_chair:
		target_chair.occupant = null
		position.y = target_chair.position.y + 5
		scale.x = -1 * sign(position.x - target_chair.scale.x)
		#$InteractivePrompt.hide()
		target_chair = null
	position.x += move_speed * sign(scale.x) * delta


func _on_visible_on_screen_notifier_2d_screen_exited():
	if state == "exiting":
		queue_free()

func _on_interactive_prompt_interacted():
	just_interacted_with = true
