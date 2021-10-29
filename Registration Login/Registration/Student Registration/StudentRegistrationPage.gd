extends CanvasLayer


# Declare member variables here. Examples:
var email
var password
var cfm_password
var selectedClass = 'Class-A'


# Called when the node enters the scene tree for the first time.
func _ready():
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
	
	if password == cfm_password:
		# navigate to character selectiom page
		var namePage = preload("res://Registration Login/Registration/Student Registration/GetNamePage.tscn").instance()
		namePage.init(email, password, selectedClass)
		get_tree().root.add_child(namePage)
	else:
		$NoMatchLabel.show()

func _on_BackButton_pressed():
	# navigate back to previous page
	get_tree().change_scene("res://Registration Login/Registration/RegisterRoleSelectPage.tscn")


func _on_ClassDropdownButton_item_selected(index):
	if index == 0:
		selectedClass = 'Class-A'
	elif index == 1:
		selectedClass = 'Class-B'
	elif index == 2:
		selectedClass = 'Class-C'
	elif index == 3:
		selectedClass = 'Class-D'
