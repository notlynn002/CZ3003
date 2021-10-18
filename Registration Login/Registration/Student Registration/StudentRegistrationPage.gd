extends CanvasLayer


# Declare member variables here. Examples:
var email
var password
var cfm_password
var classIndex


# Called when the node enters the scene tree for the first time.
func _ready():
	$MuteButton.hide() # dont show sound off icon until it is pressed
	$NoMatchLabel.hide()
	# add class list from db into option button (ClassDropdownButton)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ContinueButton_pressed():
	password = $PasswordInput.text
	cfm_password = $ConfirmPasswordInput.text
	email = $EmailInput.text
	print(classIndex)
	
	if password == cfm_password:
		# navigate to character selectiom page
		var namePage = preload("res://Registration Login/Registration/Student Registration/GetNamePage.tscn").instance()
		namePage.init(email, password, classIndex)
		get_tree().root.add_child(namePage)
	else:
		$NoMatchLabel.show()

func _on_BackButton_pressed():
	# navigate back to previous page
	get_tree().change_scene("res://Registration Login/Registration/RegisterRoleSelectPage.tscn")


func _on_SoundButton_pressed():
	$SoundButton.hide() # stop displaying sound on icon
	# stop playing background music
	$MuteButton.show() # display sound off icon


func _on_MuteButton_pressed():
	$MuteButton.hide() # stop displaying sound off icon
	# starts playing background music
	$SoundButton.show() # display sound on icon


func _on_ClassDropdownButton_item_selected(index):
	classIndex = index
