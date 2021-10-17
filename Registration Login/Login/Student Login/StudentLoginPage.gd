extends CanvasLayer


# Declare member variables here. Examples:
var email
var password

# Called when the node enters the scene tree for the first time.
func _ready():
	$Popup.hide()
	$MuteButton.hide() # dont show sound off icon until it is pressed
	Firebase.Auth.connect("login_succeeded", self, "_on_FirebaseAuth_login_succeeded")
	Firebase.Auth.connect("login_failed", self, "_on_login_failed")

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


func _on_LoginButton_pressed():
	email = $EmailInput.text
	password = $PasswordInput.text
	login(email, password, 'student')
	
	
######## ALL BACKEND FUNCTIONS #########
func _on_login_failed(error_code, message):
	print("dd")
	Globals.currUser = null
	print("error code: " + str(error_code))
	print("message: " + str(message))
	$Popup.show()


func login(email, password, role):
	Firebase.Auth.login_with_email_and_password("admin@gmail.com", "cz3003ssad")
	var query :FirestoreQuery = FirestoreQuery.new() 
	query.from('User')
	query.where('email', FirestoreQuery.OPERATOR.EQUAL, email)
	var query_task :FirestoreTask = Firebase.Firestore.query(query)
	var result : Array = yield(query_task, 'task_finished')

	if result == []:
		print("No account found with this email")
		$Popup.show()
	elif result[0].doc_fields.role != role:
		print("you are not authorised to log in as a "+ role)
		$Popup.show()
	else:
		var res = result[0].doc_fields
		res["userId"] = result[0].doc_name
		Globals.currUser = res
			
		Firebase.Auth.login_with_email_and_password(email, password)
	

	
func _on_FirebaseAuth_login_succeeded(auth_info):

	if auth_info.localid != "bKVRE45BXPY2R8RhochyJlefPW92":
		print("login succcess!")
		Firebase.Auth.save_auth(auth_info)
		
		get_tree().change_scene("res://Game Play/StudentHomePage.tscn")
		
	# change scene
	pass


func _on_CloseButton_pressed():
	$Popup.hide()
