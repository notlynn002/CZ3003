extends CanvasLayer


# Declare member variables here. Examples:
var teacher_name
var password

# Called when the node enters the scene tree for the first time.
func _ready():
	$MuteButton.hide() # dont show sound off icon until it is pressed
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_BackButton_pressed():
	# navigate back to previous page
	get_tree().change_scene("res://Registration Login/Login/LoginRoleSelectPage.tscn")


func _on_MuteButton_pressed():
	$MuteButton.hide() # stop displaying sound off icon
	# starts playing background music
	$SoundButton.show() # display sound on icon


func _on_SoundButton_pressed():
	$SoundButton.hide() # stop displaying sound on icon
	# stop playing background music
	$MuteButton.show() # display sound off icon


func _on_NameInput_text_entered(name):
	teacher_name = name


func _on_PasswordInput_text_entered(pw):
	password = pw


func _on_LoginButton_pressed():
	pass # Replace with function body.
	# check if name and pw match then
	# navigate to teacher's home page
