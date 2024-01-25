extends StaticBody2D

var player

func _ready():
	player = get_tree().get_first_node_in_group("Player")

func _on_interactive_prompt_interacted():
	if is_instance_valid(player.held_item):
		player.held_item.queue_free()
		$Player.play()
