extends Camera2D

onready var player = get_node("/root/NormalLevel/King")

func _process(delta):
	position.x = player.position.x
