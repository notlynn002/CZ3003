extends HBoxContainer

enum MODES {empty}

var heart_full = preload("res://sprites/tower/full heart.png")
var heart_empty = preload("res://sprites/tower/empty heart.png")

export (MODES) var mode = MODES.empty

func update_health(value):
	match mode:
		MODES.empty:
			update_empty(value)

func update_empty(value):
	for i in get_child_count():
		if value > i:
			get_child(i).texture = heart_full
		else:
			get_child(i).texture = heart_empty
