extends StaticBody2D

@export var holdable_item_resource: OrderResource

@onready var holdable_item_scene : PackedScene = preload("res://holdable_items/scenes/holdable_item_scene.tscn")

var player

func _ready():
	player = get_tree().get_first_node_in_group("Player")

func _on_interactive_prompt_interacted():
	if !player.held_item:
		var item = holdable_item_scene.instantiate()
		item.item_resource = holdable_item_resource
		player.held_item = item
		player.add_child(item)
