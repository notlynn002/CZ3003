extends CanvasLayer


# Declare member variables here. Examples:
var student = ''
var tower = 0
var level = 0 
var	className = ''

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_StudentOptionbutton_item_selected(input):
	student = input

func _on_ViewTower_item_selected(input):
	tower = input

func _on_ViewLevel_item_selected(input):
	level = input

func _on_ViewClass_item_selected(input):
	className = input

func _on_BackButton_pressed():
	self.queue_free()
