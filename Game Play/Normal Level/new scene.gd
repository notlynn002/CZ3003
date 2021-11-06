extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var doorName = "numbers-01"
	var door = doorName.left(7)
	print("doorName:", doorName)
	print("door: ", door)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
