extends CanvasLayer

# Declare member variables here. Examples:

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _on_CreateQuizButton_pressed():
	var root = get_tree().root
	var createQuizPage = preload('res://Teacher/create quiz/QuizCreationPage.tscn').instance()
	root.add_child(createQuizPage)

func _on_ManageClassButton_pressed():
	get_tree().change_scene("res://Teacher/Manage Class/ManageClass.tscn")

func _on_LogoutButton_pressed():
	get_tree().change_scene("res://Registration Login/StartPage.tscn")
