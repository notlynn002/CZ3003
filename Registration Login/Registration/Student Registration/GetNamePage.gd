extends CanvasLayer


# Declare member variables here. Examples:
var student_name
var password
var email
var selectedClass

func init(emailAddr, pw, idx):
	email = emailAddr
	password = pw
	selectedClass = idx
	
# Called when the node enters the scene tree for the first time.
func _ready():
	$MuteButton.hide()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ContinueButton_pressed():
	# navigate to character selectiom page
	student_name = $Input.text
	var characterPage = preload("res://Registration Login/Registration/Student Registration/StudentCharacterSelectPage.tscn").instance()
	characterPage.init(student_name, email, password, selectedClass)
	get_tree().get_root().add_child(characterPage)
#	get_node("/root/GetNamePage").queue_free()
#	get_node("/root/StudentRegistrationPage").queue_free()

func _on_BackButton_pressed():
	self.queue_free()


func _on_SoundButton_pressed():
	$SoundButton.hide() # stop displaying sound on icon
	# stop playing background music
	$MuteButton.show() # display sound off icon


func _on_MuteButton_pressed():
	$MuteButton.hide() # stop displaying sound off icon
	# starts playing background music
	$SoundButton.show() # display sound on icon
