extends CanvasLayer


# Declare member variables here. Examples:

# Called when the node enters the scene tree for the first time.
func _ready():
	$Popup.hide()


func _on_CreateQuizButton_pressed():
	var root = get_tree().root
	var creatqQuizPage = preload('res://Teacher/create quiz/QuizCreationPage.tscn').instance()
	root.add_child(creatqQuizPage)


func _on_ManageClassButton_pressed():
	$Popup.show()
	


func _on_CreateClassButton_pressed():
	pass # Replace with function body.
	# navigate to create class page


func _on_ViewStatsButton_pressed():
	pass # Replace with function body.
	# navigate to view stats page


func _on_CloseButton_pressed():
	$Popup.hide()


func _on_LogoutButton_pressed():
	get_tree().change_scene("res://Registration Login/StartPage.tscn")
