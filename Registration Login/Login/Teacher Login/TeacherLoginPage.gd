extends CanvasLayer


# Declare member variables here. Examples:
var email
var password



# Called when the node enters the scene tree for the first time.
func _ready():
	$Popup.hide()
	Firebase.Auth.connect("login_succeeded", self, "_on_FirebaseAuth_login_succeeded")
	Firebase.Auth.connect("login_failed", self, "_on_login_failed")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_BackButton_pressed():
	# navigate back to previous page
	get_tree().change_scene("res://Registration Login/Login/LoginRoleSelectPage.tscn")


func _on_LoginButton_pressed():
	email = $EmailInput.text
	password = $PasswordInput.text
	login(email, password, 'teacher')
	
	
###### ALL THE BACKEND FUNCTIONS ######
func _on_login_failed(error_code, message):
	Globals.currUser = null
	print("error code: " + str(error_code))
	print("message: " + str(message))
	$Popup/Label.text = "Oops! Something went wrong. \n" + str(error_code) + ": "+str(message).split("_").join(" ").capitalize()
	$Popup.show()


func login(email, password, role):
	Firebase.Auth.login_with_email_and_password(email, password)	

	
func _on_FirebaseAuth_login_succeeded(auth_info):
	var query :FirestoreQuery = FirestoreQuery.new() 
	query.from('User')
	query.where('email', FirestoreQuery.OPERATOR.EQUAL, email)
	var query_task :FirestoreTask = Firebase.Firestore.query(query)
	var result : Array = yield(query_task, 'task_finished')
	
	if result[0].doc_fields.role != "teacher":
		print("you are not authorised to log in as a teacher")
		$Popup/Label.text = "you are not authorised to log in as a teacher"
		$Popup.show()
	else:
		var res = result[0].doc_fields
		res["userId"] = result[0].doc_name
		Globals.currUser = res
			
		Firebase.Auth.login_with_email_and_password(email, password)

		if auth_info.localid != "bKVRE45BXPY2R8RhochyJlefPW92":
			print("login succcess!")
			Firebase.Auth.save_auth(auth_info)
			
			get_tree().change_scene("res://Teacher/TeacherHomePage.tscn")


func _on_CloseButton_pressed():
	$Popup.hide()
