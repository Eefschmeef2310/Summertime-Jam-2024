extends Node2D

const TARGET_SLIP = preload("res://Levels/target_slip.tscn")

func _on_target_manager_targets_created(target_data):
	for target in target_data:
		var slip = TARGET_SLIP.instantiate()
		slip.set_data(target)
		add_child(slip)

func _on_target_manager_target_killed(target):
	for child in get_children():
		if child.data == target:
			child.complete_slip()
