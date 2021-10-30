extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_BackButton_pressed():
	# navigate back to start page
	get_tree().change_scene("res://Registration Login/StartPage.tscn")


func _on_TeacherButton_pressed():
	# navigate to teacher login page
	get_tree().change_scene("res://Registration Login/Login/Teacher Login/TeacherLoginPage.tscn")


func _on_StudentButton_pressed():
	# navigate to student login page
	get_tree().change_scene("res://Registration Login/Login/Student Login/StudentLoginPage.tscn")
