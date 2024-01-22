extends Node2D

var state = "entering"

var target_chair = null

func _ready():
	pass

func _process(delta):
	match state:
		"entering":
			state_entering(delta)
		"waiting_order":
			state_waiting_order()

func state_entering(delta):
	$AnimationPlayer.play("walk")
	if !target_chair:
		var chairs = get_tree().get_nodes_in_group("chair")
		for chair in chairs:
			if !chair.occupant != null:
				chair.occupant = self
				target_chair = chair
				position.y = target_chair.position.y + 5
				break
	else:
		position = position.move_toward(target_chair.position, 50 * delta)
		position.y = target_chair.position.y + 5
		if position.distance_to(target_chair.position) <= 6:
			#sit down
			state = "waiting_order"

func state_waiting_order():
	position = target_chair.position
	scale.x = target_chair.scale.x
	$AnimationPlayer.play("sit")
