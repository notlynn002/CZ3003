extends CanvasLayer

# Declare member variables here. Examples:

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _on_CreateQuizButton_pressed():
	Globals.get('quizQuestions').clear()
	var root = get_tree().root
	var createQuizPage = preload('res://Teacher/create quiz/QuizCreationPage.tscn').instance()
	createQuizPage.init()
	root.add_child(createQuizPage)

func _on_ManageClassButton_pressed():
	var root = get_tree().root
	var createManageClassPage = preload("res://Teacher/Manage Class/ManageClass.tscn").instance()
	root.add_child(createManageClassPage)

func _on_LogoutButton_pressed():
	get_tree().change_scene("res://Registration Login/StartPage.tscn")
