extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$PopupMenu.hide() # dont showpopup until one of the castle is pressed

func _on_Qn5_pressed():
	get_tree().change_scene("res://Game Play/BossLevel.tscn")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Qn1_pressed():
	$PopupMenu.show() # display popup
