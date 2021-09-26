extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$MuteButton.hide() # dont show sound off icon until it is pressed
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_BackButton_pressed():
	# navigate back to start page
	get_tree().change_scene("res://Registration Login/StartPage.tscn")


func _on_SoundButton_pressed():
	$SoundButton.hide() # stop displaying sound on icon
	# stop playing background music
	$MuteButton.show() # display sound off icon


func _on_MuteButton_pressed():
	$MuteButton.hide() # stop displaying sound off icon
	# starts playing background music
	$SoundButton.show() # display sound on icon


func _on_StudentButton_pressed():
	# navigate to student registration page
	get_tree().change_scene("res://Registration Login/Registration/Student Registration/StudentRegistrationPage.tscn")


func _on_TeacherButton_pressed():
	# navigate to teacher registration page
	get_tree().change_scene("res://Registration Login/Registration/Teacher Registration/TeacherRegistrationPage.tscn")
