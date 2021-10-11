extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ViewByOptionbutton_item_selected(index):
	if index == 2:
		var root = get_tree().root
		var createViewStatsStudentPage = preload("res://Teacher/Stat/ViewStatsStudent.tscn").instance()
		root.add_child(createViewStatsStudentPage)


func _on_BackButton_pressed():
	self.queue_free()
