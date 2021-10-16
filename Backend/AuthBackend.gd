extends Control
class_name AuthBackend

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var profileDetails = null
#var currUser = null


# Called when the node enters the scene tree for the first time.
func _ready():
	Firebase.Auth.connect("login_succeeded", self, "_on_FirebaseAuth_login_succeeded")
	Firebase.Auth.connect("signup_succeeded", self, "_on_FirebaseAuth_signup_succeeded")
	Firebase.Auth.connect("login_failed", self, "_on_login_failed")
	Firebase.Auth.connect("signup_failed", self, "on_login_failed")

func on_login_failed(error_code, message):
	Globals.currUser = null
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
	
	if result == []:
		print("No account found with this email")
	elif result[0].doc_fields.role != role:
		print("you are not authorised to log in as a "+ role)
	else:
		var res = result[0].doc_fields
		res["userId"] = result[0].doc_name
		Globals.currUser = res
		print(Globals.currUser)
		
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
		print(Globals.currUser)
	# change scene
	pass



	
func signup(email, password, pd):
	Firebase.Auth.signup_with_email_and_password(email, password)
	profileDetails = pd

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
	
func _on_t_signup_button_up():
	var pd = {"name": "TestTeacher3", "role": "teacher"}
	signup("teacher3@gmail.com", "123456", pd)
	
	pass # Replace with function body.

func _on_s_signup_button_up():
	var pd = {"character": "king", "classId": "dummyClass", "name": "TestStudent007", "role": "student"}
	signup("student007@gmail.com", "123456", pd)
	pass # Replace with function body.


static func logout():
	Firebase.Auth.logout()
	Globals.currUser = null
	print("User has logged out. current user set to" + str(Globals.currUser))
	pass # Replace with function body.
func _on_logout_button_up():
	logout()
	
	

	
	


static func updateUser(updatedInfo):
	var user_collection : FirestoreCollection = Firebase.Firestore.collection("User")
	var update_task : FirestoreTask = user_collection.update(Globals.currUser.userId, updatedInfo)
	var doc : FirestoreDocument = yield(update_task, "task_finished")
	var res = doc.doc_fields
	res["userId"] = doc.doc_name
	Globals.currUser = res
	print(Globals.currUser)
	return res

func _on_updateUser_button_up():
	var updatedInfo = {"name": "studentUpdated", "characterId": 7}
	updateUser(updatedInfo)
	pass # Replace with function body.


static func getUser(id):
	var user_collection : FirestoreCollection = Firebase.Firestore.collection("User")
	user_collection.get(id)
	var doc : FirestoreDocument = yield(user_collection, "get_document")
	var res = doc.doc_fields
	res["userId"] = doc.doc_name
	print(res)
	return res


func _on_getUser_button_up():
	var id = "abbl6nQirTNVlCBERONJw3cNDd32"
	getUser(id)
	pass # Replace with function body.
	




func _on_getCurrUser_button_up():
	print(Globals.currUser)
	pass # Replace with function body.
