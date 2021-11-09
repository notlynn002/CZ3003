extends CanvasLayer


# Declare member variables here. Examples:

var classBackend = preload("res://Backend/ClassBackend.tscn").instance()

var teacherid = "dummyteacher1"
# Called when the node enters the scene tree for the first time.
func _ready():
	#print(yield(classBackend.get_class_ids(testTeacherID),"completed"))
	$CreateClass.hide()

func _on_CreateClassButton_pressed():
	$CreateClass.show()

func _on_ViewStatsButton_pressed():
	var root = get_tree().root
	var createStatsPage = preload("res://Teacher/Stat/ViewStatsClass.tscn").instance()
	createStatsPage.init(teacherid, classBackend)
	root.add_child(createStatsPage)

func _on_ManageClose_pressed():
	self.queue_free()

func _on_CreateClose_pressed():
	$CreateClass.hide()

func _on_LogoutButton_pressed():
	get_tree().change_scene("res://Registration Login/StartPage.tscn")

func _on_SaveButton_pressed():
	var className = $CreateClass/NameInput.text
	var classes = yield(ClassBackend.get_class_names(teacherid), "completed")
	print(classes)
	
	if className in classes:
		$SameClassPopup.show()
	else:
		classBackend.create_class(teacherid, className)
		$CreateClass.hide()


func _on_SameClassPopup_mouse_entered():
	$SameClassPopup.hide()
