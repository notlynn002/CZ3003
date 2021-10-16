extends CanvasLayer


# Declare member variables here. Examples:
var character
var student_name
var email
var password
var classIndex
var profileDetails

func init(sName, emailAddr, pw, idx):
	student_name = sName
	email = emailAddr
	password = pw
	classIndex = idx


# Called when the node enters the scene tree for the first time.
func _ready():
	$MuteButton.hide() # dont show sound off icon until it is pressed
	Firebase.Auth.connect("signup_succeeded", self, "_on_FirebaseAuth_signup_succeeded")
	Firebase.Auth.connect("signup_failed", self, "on_login_failed")


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
	var pd = {"character": character, "classID": classIndex, "name": student_name, "role": "student"}
	signup(email, password, pd)
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
	return res

	

	

	
	






