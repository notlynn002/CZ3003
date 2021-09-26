extends CanvasLayer


# Declare member variables here. Examples:
var character


# Called when the node enters the scene tree for the first time.
func _ready():
	$MuteButton.hide() # dont show sound off icon until it is pressed
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_BackButton_pressed():
	# navigate back to previous page
	get_tree().change_scene("res://Registration Login/Registration/Student Registration/StudentRegistrationPage.tscn")


func _on_SoundButton_pressed():
	$SoundButton.hide() # stop displaying sound on icon
	# stop playing background music
	$MuteButton.show() # display sound off icon


func _on_MuteButton_pressed():
	$MuteButton.hide() # stop displaying sound off icon
	# starts playing background music
	$SoundButton.show() # display sound on icon


func _on_RegisterButton_pressed():
	pass # Replace with function body.
	# navigate to student home screen


func _on_SamuraiButton_pressed():
	character = "samurai" # or however the backend stores character


func _on_ArcherButton_pressed():
	character = "archer" # or however the backend stores character


func _on_HuntressButton_pressed():
	character = "huntress" # or however the backend stores character


func _on_KingButton_pressed():
	character = "king" # or however the backend stores character
