extends CanvasLayer


# Declare member variables here. Examples:
var teacher_name
var password
var cfm_password
var email
var profileDetails

# Called when the node enters the scene tree for the first time.
func _ready():
	$NoMatchLabel.hide()
	$Popup.hide()
	Firebase.Auth.connect("signup_succeeded", self, "_on_FirebaseAuth_signup_succeeded")
	Firebase.Auth.connect("signup_failed", self, "_on_login_failed")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_BackButton_pressed():
	# navigate back to previous page
	get_tree().change_scene("res://Registration Login/Registration/RegisterRoleSelectPage.tscn")


func _on_ConfirmPasswordInput_text_entered(cfm_pw):
	cfm_password = cfm_pw
	
	if password == cfm_password:
		$NoMatchLabel.hide()
	else:
		$NoMatchLabel.show()


func _on_RegisterButton_pressed():
	email = $EmailInput.text
	password = $PasswordInput.text
	var pd = {"name": $NameInput.text, "role": "teacher"}
	signup(email, password,pd )
	

########## ALL THE BACKEND FUNCTIONS ############
func signup(email, password, pd):
	profileDetails = pd
	Firebase.Auth.signup_with_email_and_password(email, password)

func _on_FirebaseAuth_signup_succeeded(auth_info):
	print("Sign up success!")
	Firebase.Auth.save_auth(auth_info)
	createProfile(auth_info)

func createProfile(auth_info):
	var user_collection : FirestoreCollection = Firebase.Firestore.collection("User")
	profileDetails['email'] = auth_info.email
	var add_user_task :FirestoreTask = user_collection.add(auth_info.localid, profileDetails)
	var addedUser : FirestoreDocument = yield(add_user_task, "task_finished")
	var res = addedUser.doc_fields
	res["userId"] = addedUser.doc_name
	Globals.currUser = res
	get_tree().change_scene("res://Teacher/TeacherHomePage.tscn")
	
func _on_login_failed(error_code, message):
	Globals.currUser = null
	profileDetails = null
	print("error code: " + str(error_code))
	print("message: " + str(message))
	$Popup/Label.text = str(message)
	$Popup.show()
	



func _on_CloseButton_pressed():
	$Popup.hide()
