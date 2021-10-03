extends Control



func _ready():
	pass # Replace with function body.


# Get all towers available in database. doc_name = towerID
func _on_Get_all_towers_button_up():
	var query : FirestoreQuery = FirestoreQuery.new()
	query.from('Tower')
	
	var query_task : FirestoreTask = Firebase.Firestore.query(query)
	var result = yield(query_task, 'task_finished')
	print(result)


func get_level_for_tower(towerID):
	var query : FirestoreQuery = FirestoreQuery.new()
	query.from('Level')
	query.where('towerID', FirestoreQuery.OPERATOR.EQUAL, towerID)
	query.order_by('level', FirestoreQuery.DIRECTION.ASCENDING)
	
	var query_task : FirestoreTask = Firebase.Firestore.query(query)
	var result = yield(query_task, 'task_finished')
	print(result)
	
	
func _on_Get_levels_for_1_tower_button_up():
	get_level_for_tower('fraction-tower')
	pass

func get_questions_by_level(levelID):
	var query : FirestoreQuery = FirestoreQuery.new()
	query.from('Question')
	query.where('levelID', FirestoreQuery.OPERATOR.EQUAL, levelID)
	
	var query_task : FirestoreTask = Firebase.Firestore.query(query)
	var result: Array = yield(query_task, 'task_finished')
	var res:Array = []
	for i in result:
		res.append(i.doc_fields)
	var sm : Array = [1,2,3]
	print(typeof(res))
	
	print(res)
	
func _on_Get_questions_by_level_button_up():
	get_questions_by_level('dummylevel1')
	pass # Replace with function body.
	

func _generate_id(collection_name: String) -> String:
	var task: FirestoreTask
	
	# get the current id
	var collection: FirestoreCollection = Firebase.Firestore.collection(collection_name)
	task = collection.get("id")
	var id_doc: FirestoreDocument = yield(task, "task_finished")
	var id: int = id_doc.doc_fields["id"]
	
	# increment the id and write it back to the collection
	task = collection.update("id", {"id": id+1})
	yield(task, "task_finished")
	
	return str(id)
	
	
# Returns Array<FirestoreDocument>
func get_level_attempt(student_id: String, level_id: String, best: bool) -> Array:
	var query
	var task: FirestoreTask
	
	# Get question ids of question in level
	query = FirestoreQuery.new()
	query.from("Question")
	query.where("levelID", FirestoreQuery.OPERATOR.EQUAL, level_id)
	task = Firebase.Firestore.query(query)
	var question_docs: Array = yield(task, "task_finished") # Array<FirestoreDocument>
	
	# Query question attempts
	var question_attempt: Dictionary
	var question_attempts: Array = []
	for question_doc in question_docs:
		var question_id: String = question_doc.doc_name
		query = _get_question_attempt(student_id, question_id, best)
		question_attempt = yield(query, "completed")
		question_attempts.append(question_attempt)
	
	return question_attempts
	
	
func _get_question_attempt(student_id: String, question_id: String,  best: bool) -> Dictionary:
	var query: FirestoreQuery = FirestoreQuery.new()
	query.from("Question_Attempt")
	query.where("studentID", FirestoreQuery.OPERATOR.EQUAL, student_id)
	query.where("best", FirestoreQuery.OPERATOR.EQUAL, best)
	query.where("questionID", FirestoreQuery.OPERATOR.EQUAL, question_id)
	var task: FirestoreTask = Firebase.Firestore.query(query)
	var data: Array =  yield(task, "task_finished") # Array<FirestoreDocument>
	return data[0].doc_fields
	

# question_attempts: Array<Dictionary>
func submit_attempts(student_id: String, question_attempts: Array):
	var temp
	var id: String
	var task: FirestoreTask
	var collection: FirestoreCollection = Firebase.Firestore.collection("Question_Attempt")
	for question_attempt in question_attempts:
		temp = _generate_id("Question_Attempt")
		id = yield(temp, "completed")
		question_attempt["studentID"] = student_id
		task = collection.add(id, question_attempt)
		yield(task, "task_finished")


func _on_Get_level_attempt_button_up():
	var output = get_level_attempt("dummystudent1", "dummylevel1", false)
	output = yield(output, "completed")
	print(output)


func _on_sumbit_attempt_button_up():
	var attempt1: Dictionary = {"best": true, "questionID": "dummyqn1", "stuAttemptDuration": 340, "stuAttemptStatus": false}
	var attempt2: Dictionary = {"best": true, "questionID": "dummyqn2", "stuAttemptDuration": 102, "stuAttemptStatus": true}
	var attempt3: Dictionary = {"best": true, "questionID": "dummyqn3", "stuAttemptDuration": 100, "stuAttemptStatus": true}
	var output = submit_attempts("dummystudent1", [attempt1, attempt2, attempt3])
	output = yield(output, "completed")
	print("submit_attempts() successful")

