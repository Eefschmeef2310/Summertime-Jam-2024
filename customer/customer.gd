extends Node2D

@onready var interactive_prompt = $InteractivePrompt
@onready var sprite_2d = $Sprite2D
@onready var sprite_2df = $Sprite2DF
@onready var sprite_2dh = $Sprite2DH
@onready var sprite_2ds = $Sprite2DS
@onready var sprite_2d_hands = $Sprite2DHands
@onready var order_pref_sprite = $OrderPrefSprite

var player

var state = "entering"

var target_chair = null
var just_entered_state = false
var just_interacted_with = false

var move_speed = 75

var target_manager
var tutorial_manager
var data: CustomerData

var poisoned = false

var facing = 1

@export var timer_color : Gradient
@onready var order_timer_visual : TextureProgressBar = $OrderCountdown/TextureProgressBar
@onready var order_timer : Timer = $OrderCountdown/TextureProgressBar/OrderTimer

@onready var holdable_item_scene : PackedScene = preload("res://holdable_items/scenes/holdable_item_scene.tscn")
var holdable_item: HoldableItemScene
var holdable_item_x: float

@export var animation_players: Array[AnimationPlayer]

func _ready():
	interactive_prompt.enabled = false
	
	#Initialise timer
	order_timer_visual.max_value = order_timer.wait_time
	
	player = get_tree().get_first_node_in_group("Player")
	target_manager = get_tree().get_first_node_in_group("target_manager")
	tutorial_manager = get_tree().get_first_node_in_group("tutorial_manager")
	if target_manager:
		data = target_manager.generate_new_customer_data()
		#if data.is_target:
			#$TargetLabel.show()
	elif tutorial_manager:
		data = tutorial_manager.get_data($OrderCountdown)
	
	holdable_item_x = $FoodMarker.position.x
	
	holdable_item = holdable_item_scene.instantiate()
	holdable_item.item_resource = data.order_pref
	holdable_item.cooked = true
	holdable_item.poisoned = poisoned
	$FoodMarker.add_child(holdable_item)
	
	(holdable_item.material as ShaderMaterial).set_shader_parameter("alpha", 0)

func _process(delta):
	var should_flip = (facing < 0)
	sprite_2d.flip_h = should_flip
	sprite_2df.flip_h = should_flip
	sprite_2dh.flip_h = should_flip
	sprite_2ds.flip_h = should_flip
	sprite_2d_hands.flip_h = should_flip
	
	var n = 1
	if should_flip:
		n = -1
	$FoodMarker.position.x = holdable_item_x * n
	
	#Update texture progress bar
	order_timer_visual.value = order_timer.time_left
	order_timer_visual.modulate = timer_color.sample(1.0 - order_timer_visual.value / order_timer_visual.max_value)
	
	#play ticker when low time
	if order_timer_visual.visible:
		if !$OrderCountdown/Ticker.playing and order_timer_visual.value < 0.25 * order_timer_visual.max_value:
			$OrderCountdown/Ticker.play()
			$OrderCountdown/TextureProgressBar/AnimationPlayer.play("TimerBounce")
		elif $OrderCountdown/Ticker.playing and order_timer_visual.value >= 0.25 * order_timer_visual.max_value:
			$OrderCountdown/Ticker.stop()
			$OrderCountdown/TextureProgressBar/AnimationPlayer.stop()
	
	match state:
		"entering":
			state_entering(delta)
		#"waiting_order":
			#state_waiting_order()
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
		var free_chairs = []
		for chair in chairs:
			if chair.occupant == null:
				free_chairs.append(chair)
		var chair = free_chairs.pick_random()
		chair.occupant = self
		target_chair = chair
		position.y = target_chair.position.y + 5
	else:
		position = position.move_toward(target_chair.position, move_speed * delta)
		position.y = target_chair.position.y + 5
		facing = -1 * sign(position.x - target_chair.position.x)
		if position.distance_to(target_chair.position) <= 6:
			#sit down
			just_interacted_with = false
			just_entered_state = true
			state = "waiting_food"

#func state_waiting_order():
	#if just_entered_state:
		##Start timer
		#order_timer.start()
		#order_timer_visual.visible = true
		#
		#play_animation("sit")
		#just_entered_state = false
	#
	#elif !$AnimationPlayer.is_playing():
		#play_animation("sit_hold")
	#
	#position = target_chair.position
	#facing = target_chair.scale.x
	#
	#interactive_prompt.enabled = true
	#if just_interacted_with:
		#just_interacted_with = false
		#just_entered_state = true
		#state = "waiting_food"

func state_waiting_food():
	if just_entered_state:
		if tutorial_manager:
			tutorial_manager.phase_complete()
		
		#Start timer
		order_timer.start()
		order_timer_visual.visible = true
		
		order_pref_sprite.texture = data.order_pref.cooked_texture
		order_pref_sprite.show()
		
		$StartHabitTimer.start()
		
		play_animation("sit")
		just_entered_state = false
	
	position = target_chair.position
	facing = target_chair.scale.y
	
	(holdable_item.material as ShaderMaterial).set_shader_parameter("alpha", 0)
	if interactive_prompt.visible and is_instance_valid(player.held_item) and player.held_item.item_resource == data.order_pref:
		(holdable_item.material as ShaderMaterial).set_shader_parameter("alpha", 0.5)
	
	interactive_prompt.enabled = true
	if just_interacted_with:
		if is_instance_valid(player.held_item):
			var player_food_holding: OrderResource = player.held_item.item_resource
			if data.order_pref == player_food_holding:
				# correct food
				if player.held_item.cooked:
					
					$Streams/OrderComplete.play()
					
					if tutorial_manager:
						tutorial_manager.phase_complete()
					
					# cooked food
					if player.held_item.poisoned:
						poisoned = true
					just_entered_state = true
					player.held_item.queue_free()
					state = "eat"
					
					#update score. Score is 0.1 * the amount of time left as a percentage
					ScoreManager.score += ceil(100 * (order_timer.time_left / order_timer.wait_time))
				else:
					# uncooked food
					print("This isn't cooked! Are you trying to poison me?")
			else:
				# incorrect food
				print("Incorrect food!")
		just_interacted_with = false

func state_eat():
	interactive_prompt.enabled = false
	if just_entered_state:
		order_pref_sprite.show()
		$AnimationPlayerHands.play("eat")
		$DieFromPoisonTimer.start()
		$ExitTimer.start()
		play_animation("eat")
		holdable_item.poisoned = poisoned
		(holdable_item.material as ShaderMaterial).set_shader_parameter("alpha", 1)
		order_timer.stop()
		order_timer_visual.hide()
		order_pref_sprite.hide()
		just_entered_state = false
		#if !poisoned and !data.is_target:
			#ScoreManager.score += 

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
		holdable_item.queue_free()
	position.x += move_speed * sign(facing) * delta

func set_textures_for_animation(s: String):
	$Sprite2DH.texture = data.headpiece.get("texture_" + s)
	$Sprite2DS.texture = data.clothing.get("texture_" + s)

func _on_visible_on_screen_notifier_2d_screen_exited():
	if state == "exiting":
		if tutorial_manager:
			tutorial_manager.phase_complete()
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
		$DeathCheckIfTargetTimer.start()
	else:
		if data.is_target:
			GameOverManager.game_over("You let a target get away!")

func _on_exit_timer_timeout():
	state = "exiting"
	
func _on_order_timer_timeout():
	order_timer_visual.visible = false
	GameOverManager.game_over("An order ran out of time!")

func _on_death_check_if_target_timer_timeout():
	if target_manager:
		target_manager.customer_killed(data)


func _on_start_habit_timer_timeout():
	# Play animations
	play_animation("sit_hold")
	$AnimationPlayerHands.play(data.habit.anim_name.pick_random())
	just_entered_state = false
