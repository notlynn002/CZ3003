extends CanvasLayer


# Declare member variables here. Examples:
var classBackend = preload("res://Backend/ClassBackend.tscn").instance()

var testTeacherID = "BXLFZaJZccaDPaxeI2Kut8MpQKl2 "
# Called when the node enters the scene tree for the first time.
func _ready():
	#print(yield(classBackend.get_class_ids(testTeacherID),"completed"))
	$CreateClass.hide()

func _on_CreateClassButton_pressed():
	$CreateClass.show()

func _on_ViewStatsButton_pressed():
	get_tree().change_scene("res://Teacher/Stat/ViewStatsClass.tscn")

func _on_ManageClose_pressed():
	get_tree().change_scene("res://Teacher/TeacherHomePage.tscn")

func _on_CreateClose_pressed():
	$CreateClass.hide()

func _on_LogoutButton_pressed():
	get_tree().change_scene("res://Registration Login/StartPage.tscn")

func _on_SaveButton_pressed():
	var className = $CreateClass/NameInput.text
	classBackend.create_class(testTeacherID, className)
	$CreateClass.hide()
	#assume updating db of classes, which will update the optionButton in StudentRegistrationPage
	
