extends Node2D

@onready var interactive_prompt = $InteractivePrompt
@onready var sprite_2d = $Sprite2D
@onready var sprite_2df = $Sprite2DF
@onready var sprite_2dh = $Sprite2DH
@onready var sprite_2ds = $Sprite2DS
@onready var sprite_2d_hands = $Sprite2DHands


var state = "entering"

var target_chair = null
var just_entered_state = false
var just_interacted_with = false

var move_speed = 75

var target_manager
var data: CustomerData

var poisoned = false

var facing = 1

@export var animation_players: Array[AnimationPlayer]

func _ready():
	interactive_prompt.enabled = false
	var target_manager = get_tree().get_first_node_in_group("target_manager")
	if target_manager:
		data = target_manager.generate_new_customer_data()
		if data.is_target:
			$TargetLabel.show()

func _process(delta):
	var should_flip = (facing < 0)
	sprite_2d.flip_h = should_flip
	sprite_2df.flip_h = should_flip
	sprite_2dh.flip_h = should_flip
	sprite_2ds.flip_h = should_flip
	sprite_2d_hands.flip_h = should_flip
	match state:
		"entering":
			state_entering(delta)
		"waiting_order":
			state_waiting_order()
		"waiting_food":
			state_waiting_food()
		"exiting":
			state_exiting(delta)

func _on_interactive_prompt_interacted():
	just_interacted_with = true

func play_animation(s):
	for ap in animation_players:
		ap.play(s)

func state_entering(delta):
	play_animation("walk")
	if !target_chair:
		var chairs = get_tree().get_nodes_in_group("chair")
		for chair in chairs:
			if chair.occupant == null:
				chair.occupant = self
				target_chair = chair
				position.y = target_chair.position.y + 5
				break
	else:
		position = position.move_toward(target_chair.position, move_speed * delta)
		position.y = target_chair.position.y + 5
		facing = -1 * sign(position.x - target_chair.position.x)
		if position.distance_to(target_chair.position) <= 6:
			#sit down
			state = "waiting_order"
			just_entered_state = true

func state_waiting_order():
	if just_entered_state:
		play_animation("sit")
		just_entered_state = false
	
	elif !$AnimationPlayer.is_playing():
		
		play_animation("sit_hold")
	
	position = target_chair.position
	facing = target_chair.scale.x
	
	interactive_prompt.enabled = true
	if just_interacted_with:
		print("Thanks for taking my order!")
		just_interacted_with = false
		just_entered_state = true
		state = "waiting_food"
		print(data.habit.description)

func state_waiting_food():
	if just_entered_state:
		$AnimationPlayerHands.play(data.habit.anim_name.pick_random())
		just_entered_state = false
	
	position = target_chair.position
	facing = target_chair.scale.x
	
	interactive_prompt.enabled = true
	if just_interacted_with:
		print("Thanks for the food!")
		just_interacted_with = false
		state = "exiting"

func state_exiting(delta):
	$AnimationPlayerHands.play("none")
	play_animation("walk")
	if target_chair:
		target_chair.occupant = null
		position.y = target_chair.position.y + 5
		facing = -1 * sign(target_chair.scale.x)
		interactive_prompt.enabled = false
		target_chair = null
	position.x += move_speed * sign(facing) * delta

func set_textures_for_animation(s: String):
	$Sprite2DH.texture = data.headpiece.get("texture_" + s)
	$Sprite2DS.texture = data.clothing.get("texture_" + s)

func _on_visible_on_screen_notifier_2d_screen_exited():
	if state == "exiting":
		queue_free()
