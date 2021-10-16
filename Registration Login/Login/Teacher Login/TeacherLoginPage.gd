extends CanvasLayer


# Declare member variables here. Examples:
var email
var password



# Called when the node enters the scene tree for the first time.
func _ready():
	$MuteButton.hide() # dont show sound off icon until it is pressed
	Firebase.Auth.connect("login_succeeded", self, "_on_FirebaseAuth_login_succeeded")
	Firebase.Auth.connect("login_failed", self, "_on_login_failed")


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


func _on_LoginButton_pressed():
	email = $EmailInput.text
	password = $PasswordInput.text
	login(email, password, 'teacher')
	
	
###### ALL THE BACKEND FUNCTIONS ######
func on_login_failed(error_code, message):
	Globals.currUser = null

	print("error code: " + str(error_code))
	print("message: " + str(message))


func login(email, password, role):
	Firebase.Auth.login_with_email_and_password("admin@gmail.com", "cz3003ssad")
	var query :FirestoreQuery = FirestoreQuery.new() 
	query.from('User')
	query.where('email', FirestoreQuery.OPERATOR.EQUAL, email)
	var query_task :FirestoreTask = Firebase.Firestore.query(query)
	var result : Array = yield(query_task, 'task_finished')
	print(result)
	if result == []:
		print("No account found with this email")
	elif result[0].doc_fields.role != role:
		print("you are not authorised to log in as a "+ role)
	else:
		var res = result[0].doc_fields
		res["userId"] = result[0].doc_name
		Globals.currUser = res
		
		Firebase.Auth.login_with_email_and_password(email, password)
	

	
func _on_FirebaseAuth_login_succeeded(auth_info):
	
	if auth_info.localid != "bKVRE45BXPY2R8RhochyJlefPW92":
		print("login succcess!")
		Firebase.Auth.save_auth(auth_info)
		print(Globals.currUser)
		get_tree().change_scene("res://Teacher/TeacherHomePage.tscn")
		
	# change scene

