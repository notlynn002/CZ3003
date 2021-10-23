extends Area2D

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if get_overlapping_bodies().size() > 0:
			next_level()

func next_level():
	get_tree().change_scene("res://Game Play/Normal Level/NormalLevel.tscn")
