extends Node


# Collection IDs
var question_attempt = "Question_Attempt"


# Called when the node enters the scene tree for the first time.
func _ready():
	Firebase.Auth.login_with_email_and_password("test@maildrop.cc", "password")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _test_functions():
	# Insert function to test below
	#getQuestionAttempt("dummystudent1", "dummyqn1", false)
	#var collection : FirestoreCollection = Firebase.Firestore.collection("Question_Attempt")
	#var task = Firebase.Firestore.list(question_attempt)
	#var task: FirestoreTask = collection.get("dummyattempt1")
	
	#var output = yield(task, "listed_documents")
	var test = Firebase.Firestore.auth
	print(test)
	var test1 = Firebase.Firestore.collections
	print(test1)
	#var collection :FirestoreCollection = test["Question_Attempt"]
	#var task: FirestoreTask = collection.get("dummyattempt1")
	#var output = yield(task, "task_finished")
	#print(output)

	

func _query_data(query: FirestoreQuery) -> Array:
	var task: FirestoreTask = Firebase.Firestore.query(query)
	var output: Array =  yield(task, "task_finished")
	return output


func getLevelAttempt():
	pass


func getQuestionAttempt(student_id: String, question_id: String,  best: bool):
	var query: FirestoreQuery = FirestoreQuery.new()
	query.from(question_attempt)
	query.where("studentID", FirestoreQuery.OPERATOR.EQUAL, student_id)
	query.where("questionID", FirestoreQuery.OPERATOR.EQUAL, question_id)
	query.where("best", FirestoreQuery.OPERATOR.EQUAL, best)
	var task: FirestoreTask = Firebase.Firestore.query(query)
	var output =  yield(task, "task_finished")
	print(output)
