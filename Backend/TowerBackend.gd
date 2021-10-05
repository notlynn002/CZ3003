extends Control



func _ready():
	Firebase.Auth.login_with_email_and_password("test@maildrop.cc", "password")


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
	
	
func get_level_attempt(student_id: String, level_id: String, best: bool) -> Array:
	""" Gets the level question attempts for a student.
	
	Args:
		student_id (String): Student ID.
		level_id (String): Level ID.
		best (bool): True for best attempts, false for first attempt.
	
	Returns:
		Array[Dictionary]: The question attempts as Dictionary objects.
	
	Raises:
		ERR_INVALID_PARAMETER: If there are no attempts for the specific student_id, level_id and best values.
	
	"""
	# Get question ids of question in level
	var query = FirestoreQuery.new()
	query.from("Question", false)
	query.where("levelID", FirestoreQuery.OPERATOR.EQUAL, level_id)
	var task: FirestoreTask = Firebase.Firestore.query(query)
	var question_docs: Array = yield(task, "task_finished") # Array<FirestoreDocument>
	if not question_docs:
		return $error.raise_invalid_parameter_error("'%s' is not a valid level ID" % level_id)
	
	# Query question attempts
	var question_attempt
	var question_attempts: Array = []
	for question_doc in question_docs:
		var question_id: String = question_doc.doc_name
		query = _get_question_attempt(student_id, question_id, best)
		question_attempt = yield(query, "completed")
		if (question_attempt is int):
			return $error.raise_invalid_parameter_error("Either 'student_id' or 'best' has an invalid value")
		question_attempts.append(question_attempt)
	
	return question_attempts
	
	
func _get_question_attempt(student_id: String, question_id: String,  best: bool) -> Dictionary:
	""" Gets a question attempt for a student.
	
	Args:
		student_id (String): Student ID.
		level_id (String): Question ID.
		best (bool): True for best attempts, false for first attempt.
	
	Returns:
		Dictionary: The question attempt as a Dictionary.
	
	Raises:
		ERR_INVALID_PARAMETER: If there is no attempt for the specific student_id, question_id and best values.
	
	"""
	var query: FirestoreQuery = FirestoreQuery.new()
	query.from("Question_Attempt", false)
	query.where("studentID", FirestoreQuery.OPERATOR.EQUAL, student_id, FirestoreQuery.OPERATOR.AND)
	query.where("questionID", FirestoreQuery.OPERATOR.EQUAL, question_id, FirestoreQuery.OPERATOR.AND)
	query.where("best", FirestoreQuery.OPERATOR.EQUAL, best)
	
	var task: FirestoreTask = Firebase.Firestore.query(query)
	var data: Array =  yield(task, "task_finished")
	if not data:
		return $error.raise_invalid_parameter_error("Either 'student_id', 'question_id' or 'best' has an invalid value")
	var attempt: Dictionary
	for doc in data:
		attempt = doc.doc_fields
		if (attempt["studentID"]==student_id) and (attempt["questionID"]==question_id) and (attempt["best"]==best):
			return attempt
	return $error.raise_invalid_parameter_error("Either 'student_id', 'question_id' or 'best' has an invalid value")
	

func _check_question_attempt(question_attempt: Dictionary) -> int:
	"""Checks whether a question attempt Dictionary has the correct fields and field values.
	
	Args:
		question_attempt (Dictionary): A question attempt.
	
	Returns:
		int: OK if all fields are valid
	
	Raises:
		ERR_INVALID_PARAMETER: If there is a missing field, or if a field has an invalid value.
	
	"""
	# Check questionID
	var value = question_attempt.get("questionID")
	if not value:
		return $error.raise_invalid_parameter_error("Question attempt is missing the 'questionID' field")
	elif not value is String:
		return $error.raise_invalid_parameter_error("Question attempt does not have a String value for the 'questionID' field")
	
	# Check best and stuAttemptStatus
	for field in ["best", "stuAttemptStatus"]:
		value = question_attempt.get(field)
		if value == null:
			return $error.raise_invalid_parameter_error("Question attempt is missing the '%s' field" % field)
		elif not value is bool:
			return $error.raise_invalid_parameter_error("Question attempt does not have a bool value for the '%s' field" % field)
		
	# Check stuAttemptDuration
	value = question_attempt.get("stuAttemptDuration")
	if not value:
		return $error.raise_invalid_parameter_error("Question attempt is missing the 'stuAttemptDuration' field")
	elif not value is int:
		return $error.raise_invalid_parameter_error("Question attempt does not have an int value for the 'stuAttemptDuration' field")
	
	return OK


func submit_attempts(student_id: String, question_attempts: Array):
	"""Write a student's question attempts to the database.
	
	Args:
		student_id (String): Student ID.
		question_attempts (Array[Dictionary]): The question attempts as Dictionary objects.
		
	Raises:
		ERR_INVALID_PARAMETER: If a question attempt Dictionary has a missing or invalid field.
	
	"""
	# Check if question attempts have the correct fields
	var error: int
	for i in range(question_attempts.size()):
		error = _check_question_attempt(question_attempts[i])
		if error != OK:
			return $error.raise_invalid_parameter_error("Question attempt at index %d has a missing or invalid field" % i)
		
	var task: FirestoreTask
	var collection: FirestoreCollection = Firebase.Firestore.collection("Question_Attempt")
	for question_attempt in question_attempts:
		question_attempt["studentID"] = student_id
		task = collection.add("", question_attempt)
		yield(task, "task_finished")


func _on_Get_level_attempt_button_up():
	var output = get_level_attempt("dummystudent", "dummylevel1", false)
	output = yield(output, "completed")
	print(output)


func _on_sumbit_attempt_button_up():
	var attempt1: Dictionary = {"best": true, "questionID": "dummyqn1", "stuAttemptDuration": 340, "stuAttemptStatus": false}
	var attempt2: Dictionary = {"best": true, "questionID": "dummyqn2", "stuAttemptDuration": 102, "stuAttemptStatus": true}
	var attempt3: Dictionary = {"best": true, "questionID": "dummyqn3", "stuAttemptDuration": 100, "stuAttemptStatus": true}
	var output = submit_attempts("dummystudent1", [attempt1, attempt2, attempt3])
	if not output is int:
		output = yield(output, "completed")
	print("submit_attempts() completed")



func _on_test_button_button_up():
	var output = _get_question_attempt("dummystudent1", "dummyqn1",  false)
	output = yield(output, "completed")
	print(output)
	#print(output == ERR_INVALID_PARAMETER)


func _on_login_button_up():
	Firebase.Auth.login_with_email_and_password("test@maildrop.cc", "password")