extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var profileDetails = null
var currUser = null


# Called when the node enters the scene tree for the first time.
func _ready():
	Firebase.Auth.connect("login_succeeded", self, "_on_FirebaseAuth_login_succeeded")
	Firebase.Auth.connect("signup_succeeded", self, "_on_FirebaseAuth_signup_succeeded")
	Firebase.Auth.connect("login_failed", self, "_on_login_failed")
	Firebase.Auth.connect("signup_failed", self, "on_login_failed")

func on_login_failed(error_code, message):
	currUser = null
	profileDetails = null
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
		currUser = res
		
		Firebase.Auth.login_with_email_and_password(email, password)
	
func _on_t_login_button_up():
	login("teacher@gmail.com", "123456", "teacher")
func _on_s_login_button_up():
	login("student@gmail.com", "123456", "student")
	pass # Replace with function body.
	
func _on_FirebaseAuth_login_succeeded(auth_info):
	
	print("login succcess!")
	if auth_info.localid != "bKVRE45BXPY2R8RhochyJlefPW92":
		Firebase.Auth.save_auth(auth_info)
		print(currUser)
		return currUser
	# change scene
	pass



	
func signup(email, password):
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
	currUser = res
	return res
	
func _on_t_signup_button_up():
	profileDetails = {"name": "TestTeacher2", "role": "teacher"}
	signup("teacher2@gmail.com", "123456")
	pass # Replace with function body.

func _on_s_signup_button_up():
	profileDetails = {"characterId": 1, "classId": "dummyClass", "name": "TestStudent", "role": "student"}
	signup("student@gmail.com", "123456")
	pass # Replace with function body.


func _on_logout_button_up():
	Firebase.Auth.logout()
	profileDetails = null
	currUser = null
	print("User has logged out. current user set to" + str(currUser))
	pass # Replace with function body.
	
	

	
	




func _on_updateUser_button_up():
	var updatedInfo = {"name": "studentUpdated", "characterId": 7}
	var user_collection : FirestoreCollection = Firebase.Firestore.collection("User")
	var update_task : FirestoreTask = user_collection.update(currUser.userId, updatedInfo)
	var doc : FirestoreDocument = yield(update_task, "task_finished")
	var res = doc.doc_fields
	res["userId"] = doc.doc_name
	currUser = res
	print(currUser)
	return res
	pass # Replace with function body.




func _on_getUser_button_up():
	var id = "abbl6nQirTNVlCBERONJw3cNDd32"
	var user_collection : FirestoreCollection = Firebase.Firestore.collection("User")
	user_collection.get(id)
	var doc : FirestoreDocument = yield(user_collection, "get_document")
	var res = doc.doc_fields
	res["userId"] = doc.doc_name
	print(res)
	return res
	pass # Replace with function body.
