extends Node2D

@onready var interactive_prompt = $InteractivePrompt
@onready var sprite_2d = $Sprite2D
@onready var sprite_2df = $Sprite2DF
@onready var sprite_2dh = $Sprite2DH
@onready var sprite_2ds = $Sprite2DS
@onready var sprite_2d_hands = $Sprite2DHands

var player

var order_countdown : float = 5.

var state = "entering"

var target_chair = null
var just_entered_state = false
var just_interacted_with = false

var move_speed = 75

var target_manager
var data: CustomerData

var poisoned = false

var facing = 1

@export var timer_color : Gradient
@onready var order_timer_visual : TextureProgressBar = $OrderCountdown/TextureProgressBar
@onready var order_timer : Timer = $OrderCountdown/TextureProgressBar/OrderTimer


@export var animation_players: Array[AnimationPlayer]

func _ready():
	interactive_prompt.enabled = false
	
	#Initialise timer
	order_timer.wait_time = order_countdown
	order_timer_visual.max_value = order_countdown
	
	player = get_tree().get_first_node_in_group("Player")
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
	
	#Update texture progress bar
	order_timer_visual.value = order_timer.time_left
	order_timer_visual.modulate = timer_color.sample(1.0 - order_timer_visual.value / order_timer_visual.max_value)
	
	#play ticker when low time
	if order_timer_visual.visible:
		if !$OrderCountdown/Ticker.playing and order_timer_visual.value < 0.25 * order_timer_visual.max_value:
			#print("bingus")
			$OrderCountdown/Ticker.play()
			$OrderCountdown/TextureProgressBar/AnimationPlayer.play("TimerBounce")
		elif $OrderCountdown/Ticker.playing and order_timer_visual.value >= 0.25 * order_timer_visual.max_value:
			$OrderCountdown/Ticker.stop()
			$OrderCountdown/TextureProgressBar/AnimationPlayer.stop()
	
	match state:
		"entering":
			state_entering(delta)
		"waiting_order":
			state_waiting_order()
		"waiting_food":
			state_waiting_food()
		"exiting":
			state_exiting(delta)
		"eat":
			state_eat()
		"die":
			state_die()

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
		#Start timer
		order_timer.start()
		order_timer_visual.visible = true
		
		play_animation("sit")
		just_entered_state = false
	
	elif !$AnimationPlayer.is_playing():
		
		play_animation("sit_hold")
	
	position = target_chair.position
	facing = target_chair.scale.x
	
	interactive_prompt.enabled = true
	if just_interacted_with:
		print("I want " + data.order_pref.name + "!")
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
		if player.held_item:
			var player_food_holding: OrderResource = player.held_item.item_resource
			if data.order_pref == player_food_holding:
				#update score
				ScoreManager.score += 10 if data.is_target else 5
				# correct food
				if player.held_item.cooked:
					# cooked food
					if player.held_item.poisoned:
						print("this is poisoned...")
						poisoned = true
					print("Thanks for the food!")
					just_entered_state = true
					player.held_item.queue_free()
					state = "eat"
				else:
					# uncooked food
					print("This isn't cooked! Are you trying to poison me?")
			else:
				# incorrect food
				print("Kill yourself!")
		just_interacted_with = false

func state_eat():
	interactive_prompt.enabled = false
	if just_entered_state:
		print("YEEEEEAP")
		$AnimationPlayerHands.play("none")
		$DieFromPoisonTimer.start()
		$ExitTimer.start()
		play_animation("eat")
		just_entered_state = false

func state_die():
	interactive_prompt.enabled = false
	if just_entered_state:
		$AnimationPlayerHands.play("none")
		$ExitTimer.stop()
		play_animation("die")
		just_entered_state = false

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

func _on_death_despawn_timer_timeout():
	if target_chair:
		target_chair.occupant = null
		target_chair = null
	queue_free()


func _on_die_from_poison_timer_timeout():
	if poisoned:
		just_entered_state = true
		state = "die"
		$DeathDespawnTimer.start()


func _on_exit_timer_timeout():
	state = "exiting"
	
func _on_order_timer_timeout():
	order_timer_visual.visible = false
	GameOverManager.game_over()
