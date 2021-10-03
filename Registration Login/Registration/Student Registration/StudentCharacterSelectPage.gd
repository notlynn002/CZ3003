extends CanvasLayer


# Declare member variables here. Examples:
var character
var student_name
var email
var password
var classIndex

func init(sName, emailAddr, pw, idx):
	student_name = sName
	email = emailAddr
	password = pw
	classIndex = idx


# Called when the node enters the scene tree for the first time.
func _ready():
	$MuteButton.hide() # dont show sound off icon until it is pressed
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_BackButton_pressed():
	# navigate back to previous page
	self.queue_free()


func _on_SoundButton_pressed():
	$SoundButton.hide() # stop displaying sound on icon
	# stop playing background music
	$MuteButton.show() # display sound off icon


func _on_MuteButton_pressed():
	$MuteButton.hide() # stop displaying sound off icon
	# starts playing background music
	$SoundButton.show() # display sound on icon


func _on_RegisterButton_pressed():
	# save everything to db
	var homepage = preload("res://Game Play/StudentHomePage.tscn").instance()
	get_tree().get_root().add_child(homepage)
	get_tree().get_root().remove_child(self)


func _on_SamuraiButton_pressed():
	character = "samurai" # or however the backend stores character
	$SelectedCharacterLabel.text = character


func _on_ArcherButton_pressed():
	character = "archer" # or however the backend stores character
	$SelectedCharacterLabel.text = character

func _on_HuntressButton_pressed():
	character = "huntress" # or however the backend stores character
	$SelectedCharacterLabel.text = character

func _on_KingButton_pressed():
	character = "king" # or however the backend stores character
	$SelectedCharacterLabel.text = character
