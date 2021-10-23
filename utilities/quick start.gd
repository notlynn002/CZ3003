extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var email:String
export var password:String

export var scene:PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	Firebase.Auth.connect("login_succeeded", self, "_on_FirebaseAuth_login_succeeded")
	Firebase.Auth.connect("login_failed", self, "_on_login_failed")
	login(email, password, 'student')
	pass # Replace with function body.

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
			
		Firebase.Auth.login_with_email_and_password(email, password)
	
func _on_FirebaseAuth_login_succeeded(auth_info):

	if auth_info.localid != "bKVRE45BXPY2R8RhochyJlefPW92":
		print("login succcess!")
		print(auth_info)
		Firebase.Auth.save_auth(auth_info)
		var qnOfLevel = yield(TowerBackend.get_questions_by_level("numbers-01"),"completed")
		print(qnOfLevel)
		GlobalArray.questionBank = qnOfLevel
		get_tree().change_scene_to(scene)
		
	# change scene
	pass
	
func _on_login_failed(error_code, message):
	print("dd")
	Globals.currUser = null
	print("error code: " + str(error_code))
	print("message: " + str(message))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
