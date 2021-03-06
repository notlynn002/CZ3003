extends CanvasLayer


# Declare member variables here. Examples:
var character
var student_name
var email
var password
var selectedClass
var profileDetails

func init(sName, emailAddr, pw, idx):
	student_name = sName
	email = emailAddr
	password = pw
	selectedClass = idx


# Called when the node enters the scene tree for the first time.
func _ready():
	$Popup.hide()
	Firebase.Auth.connect("signup_succeeded", self, "_on_FirebaseAuth_signup_succeeded")
	Firebase.Auth.connect("signup_failed", self, "_on_login_failed")


func _on_BackButton_pressed():
	# navigate back to previous page
	self.queue_free()


func _on_RegisterButton_pressed():
	var pd = {"character": character, "classID": selectedClass, "name": student_name, "role": "student"}
	signup(email, password, pd)
	#var homepage = preload("res://Game Play/StudentHomePage.tscn").instance()
	#get_tree().get_root().add_child(homepage)
	#get_tree().get_root().remove_child(self)


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
	
########## ALL THE BACKEND FUNCTIONS ############
func signup(email, password, pd):
	profileDetails =pd
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
	var homepage = preload("res://Game Play/StudentHomePage.tscn").instance()
	get_tree().get_root().add_child(homepage)
	self.queue_free()
	get_node("/root/GetNamePage").queue_free()
	get_node("/root/StudentRegistrationPage").queue_free()
	
func _on_login_failed(error_code, message):
	Globals.currUser = null
	profileDetails = null
	print("error code: " + str(error_code))
	print("message: " + str(message))
	$Popup/Label.text = str(message)
	$Popup.show()
	

	

	

	
	








func _on_CloseButton_pressed():
	$Popup.hide()
