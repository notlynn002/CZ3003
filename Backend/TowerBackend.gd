extends Control

class_name TowerBackend


func _ready():
	Firebase.Auth.login_with_email_and_password("admin@gmail.com", "cz3003ssad")

static func get_all_towers():
	var query : FirestoreQuery = FirestoreQuery.new()
	query.from('Tower')
	
	var query_task : FirestoreTask = Firebase.Firestore.query(query)
	var result = yield(query_task, 'task_finished')
	var towerIds = []
	for i in result:
		towerIds.append(i.doc_name)
	return towerIds
	
# Get all towers available in database. doc_name = towerID
func _on_Get_all_towers_button_up():
	var towerIds = yield(get_all_towers(), 'completed')
	print(towerIds)


static func get_level_for_tower(towerID):
	var query : FirestoreQuery = FirestoreQuery.new()
	query.from('Level')
	query.where('towerID', FirestoreQuery.OPERATOR.EQUAL, towerID)
	query.order_by('level', FirestoreQuery.DIRECTION.ASCENDING)
	
	var query_task : FirestoreTask = Firebase.Firestore.query(query)
	var result = yield(query_task, 'task_finished')
	var levelIds = []
	for i in result:
		levelIds.append(i.doc_name)
	return levelIds
	
	
func _on_Get_levels_for_1_tower_button_up():
	get_level_for_tower('four-operations-tower')
	pass


static func get_questions_by_level(levelID):
	var query : FirestoreQuery = FirestoreQuery.new()
	query.from('Question')
	query.where('levelID', FirestoreQuery.OPERATOR.EQUAL, levelID)
	
	var query_task : FirestoreTask = Firebase.Firestore.query(query)
	var result: Array = yield(query_task, 'task_finished')
	var res:Array = []
	for i in result:
		res.append(i.doc_fields)
	var sm : Array = [1,2,3]
	#print(typeof(res))
	
	#print(res)
	return res
	
	
func _on_Get_questions_by_level_button_up():
	var qn: Array =  yield(get_questions_by_level("numbers-01"),"completed")
	print(qn[1])

	
static func get_last_level_attempted(student_id: String, tower_id: String) -> int:
	tower_id.erase(tower_id.find("-tower"), "-tower".length())
	var prev_level_no: int = 1
	var level_no: int = 1
	var qn_id: String = "%s-%02d-1" % [tower_id, level_no]
	var attempted: bool = yield(_check_first_attempt_exists(student_id, qn_id), "completed")
	while attempted:
		prev_level_no = level_no
		level_no += 1
		qn_id = "%s-%02d-1" % [tower_id, level_no]
		attempted = yield(_check_first_attempt_exists(student_id, qn_id), "completed")
	return prev_level_no
	
	
static func get_level_attempt(student_id: String, level_id: String, type: String) -> Array:
	""" Gets the level question attempts for a student.
	
	Args:
		student_id (String): Student ID.
		level_id (String): Level ID.
		type (String): Either best or false.
	
	Returns:
		Array[Dictionary]: The question attempts as Dictionary objects.
			Each Dictionary contains following keys-value pairs (all keys are Strings):
				studentID (String): Student ID of the student who made the attempt.
				questionID (String): Question ID of the question attempted.
				type (String): "best" if the attempt is the student's best attempt, "first" if it is the student's first attempt
				duration (int): Amount of time the student took to complete the question, formatted as total seconds.
				correct (bool): True if the student got the question correct, false otherwise
	
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
		return Error.raise_invalid_parameter_error("'%s' is not a valid level ID" % level_id)
	
	# Query question attempts
	var question_attempt
	var question_attempts: Array = []
	for question_doc in question_docs:
		var question_id: String = question_doc.doc_name
		question_attempt = yield(_get_question_attempt(student_id, question_id, type), "completed")
		if (question_attempt is int):
			return Error.raise_invalid_parameter_error("Either 'student_id' or 'type' has an invalid value")
		question_attempts.append(question_attempt)
	
	return question_attempts
	
	
static func _get_question_attempt(student_id: String, question_id: String,  type: String) -> Dictionary:
	""" Gets a question attempt for a student.
	
	Args:
		student_id (String): Student ID.
		level_id (String): Question ID.
		type (String): Either "best" or "first".
	
	Returns:
		Dictionary: The question attempt as a Dictionary.
	
	Raises:
		ERR_INVALID_PARAMETER: If there is no attempt for the specific student_id, question_id and best values.
	
	"""
	var collection: FirestoreCollection = Firebase.Firestore.collection("Question_Attempt")
	var attempt_id: String = "%s-%s-%s" % [student_id, question_id, type]
	var task: FirestoreTask = collection.get(attempt_id)
	var data =  yield(task, "task_finished")
	if not data is FirestoreDocument:
		return Error.raise_invalid_parameter_error("Either 'student_id', 'question_id' or 'type' has an invalid value")
	else:
		return data.doc_fields


static func _add_question_attempt(question_attempt: Dictionary):
	""" Write a question attempt to the database.
	
	Args:
		question_attempt (Dictionary): Question attempt data stored in a Dictionary. 
			The Dictionary should have the following fields:
				"questionID" (String): Question ID.
				"studentID" (String): Student ID.
				"type" (String): "best" if best attempt, "first" if first attempt.
				"correct" (bool): True if correct, false if wrong
				"duration" (int): Time taken as total seconds. 
	
	Returns:
		void
	"""
	var collection: FirestoreCollection = Firebase.Firestore.collection("Question_Attempt")
	var attempt_id = "%s-%s-%s" % [question_attempt["studentID"], question_attempt["questionID"], question_attempt["type"]]
	var task = collection.add(attempt_id, question_attempt)
	yield(task, "task_finished")
	

static func _update_question_attempt(attempt_id: String, question_attempt: Dictionary):
	""" Overwrite fields of a question attempt in the database.
	
	Args:
		question_attempt (Dictionary): Question attempt data to be updated stored in a Dictionary.
	
	Returns:
		void
	"""
	var task: FirestoreTask
	var collection: FirestoreCollection = Firebase.Firestore.collection("Question_Attempt")
	task = collection.update(attempt_id, question_attempt)
	yield(task, "task_finished")


static func _add_first_attempts(student_id: String, question_attempts: Array):
	""" Write first question attempts to the database.
	
	Args:
		student_id (String): Student ID.
		question_attempts (Array[Dictionary]): An Array of question attempt Dictionaries. 
			Each Dictionary should have the following fields:
				"questionID" (String): Question ID.
				"correct" (bool): True if correct, false if wrong
				"duration" (int): Time taken as total seconds. 
	
	Returns:
		void
	"""
	for qn_attempt in question_attempts:
		qn_attempt = qn_attempt.duplicate(true)
		qn_attempt["type"] = "first"
		qn_attempt["studentID"] = student_id
		yield(_add_question_attempt(qn_attempt), "completed")


static func _add_best_attempts(student_id: String, question_attempts: Array):
	""" Write best question attempts to the database.
	
	Args:
		student_id (String): Student ID.
		question_attempts (Array[Dictionary]): An Array of question attempt Dictionaries. 
			Each Dictionary should have the following fields:
				"questionID" (String): Question ID.
				"correct" (bool): True if correct, false if wrong
				"duration" (int): Time taken as total seconds. 
	
	Returns:
		void
	"""
	for qn_attempt in question_attempts:
		qn_attempt = qn_attempt.duplicate(true)
		qn_attempt["type"] = "best"
		qn_attempt["studentID"] = student_id
		yield(_add_question_attempt(qn_attempt), "completed")
		

static func _update_best_attempts(student_id: String, question_attempts: Array):
	""" Update best question attempts in the database.
	
	Args:
		student_id (String): Student ID.
		question_attempts (Array[Dictionary]): An Array of question attempt Dictionaries with the data to be updated.
	
	Returns:
		void
	"""
	for qn_attempt in question_attempts:
		qn_attempt = qn_attempt.duplicate(true)
		qn_attempt["type"] = "best"
		qn_attempt["studentID"] = student_id
		var attempt_id: String = "%s-%s-best" % [student_id, qn_attempt["questionID"]]
		yield(_update_question_attempt(attempt_id, qn_attempt), "completed")


static func _check_first_attempt_exists(student_id: String, question_id: String) -> bool:
	""" Check if a student has attempted a specific question.
	
	Args:
		student_id (String): Student ID.
		question_id (String): Question ID.
	
	Returns:
		bool: True if student has attempted the question, false otherwise.
	"""
	var collection: FirestoreCollection = Firebase.Firestore.collection("Question_Attempt")
	var attempt_id: String = "%s-%s-first" % [student_id, question_id]
	var task = collection.get(attempt_id)
	var result = yield(task, "task_finished")
	if result is FirestoreDocument:
		return true
	else:
		return false
	
	
static func _check_is_best_attempt(old_best_attempts: Array, new_best_attempts: Array) -> bool:
	""" Check if some new question attempts are better than some existing attempts
	
	Args:
		old_best_attempts (Array[Dictionary]): An Array of existing question attempt Dictionaries.
		new_best_attempts (Array[Dictionary]): An Array of new question attempt Dictionaries.
	
	Returns:
		bool: True if the new attempts are better than the existing ones, false otherwise.
		
	"""
	# Calculate scores and timings
	var old_score: int = 0
	var new_score: int = 0
	var old_timing: int = 0
	var new_timing: int = 0
	for i in range(old_best_attempts.size()):
		old_score += int(old_best_attempts[i]["correct"])
		new_score += int(new_best_attempts[i]["correct"])
		old_timing += old_best_attempts[i]["duration"]
		new_timing += new_best_attempts[i]["duration"]
	
	# Determine if new attempts are better than old attempts
	if old_score > new_score:
		return false
	elif old_score < new_score:
		return true
	else:
		if old_timing <= new_timing:
			return false
		else:
			return true
		
	
static func submit_attempt(student_id: String, question_attempts: Array):
	"""Write a student's question attempts to the database.
	
	This functions writes two types of attempts - first and best. 
	
	If the student has not attempted the questions before, the attempts will be written as first and best attempts.
	
	If the student has attempted the questions, 
	the function will determine if the new attempt is better than the existing best attempt.
	If it is, the function will update the best attempt.
	
	Args:
		student_id (String): Student ID.
		question_attempts (Array[Dictionary]): The question attempts as Dictionary objects.
			Each Dictionary should have the following fields:
				"questionID" (String): Question ID.
				"correct" (bool): True if correct, false if wrong
				"duration" (int): Time taken as total seconds. 
		
	Raises:
		ERR_INVALID_PARAMETER: If a question attempt Dictionary has a missing or invalid field.
	
	"""
	# Check if first attempts exists
	var qn_id: String = question_attempts[0]["questionID"] # aribitrary question id from attempts
	var exists: bool = yield(_check_first_attempt_exists(student_id, qn_id), "completed")
	if not exists:
		# First attempts does not exist, write attempts as first attempts
		yield(_add_first_attempts(student_id, question_attempts), "completed")
		yield(_add_best_attempts(student_id, question_attempts), "completed")
	else:
		# First attempt exists, check best attempt
		# Get best attempt
		var level_id = qn_id.substr(0, qn_id.length()-2)
		var old_best_attempts = yield(get_level_attempt(student_id, level_id, "best"), "completed")
		if _check_is_best_attempt(old_best_attempts, question_attempts):
			yield(_update_best_attempts(student_id, question_attempts), "completed")


func _on_Get_level_attempt_button_up():
	var output = yield(get_level_attempt("test-student1", "numbers-01", "first"), "completed")
	print(output)


func _on_sumbit_attempt_button_up():
	var attempt1: Dictionary = {"questionID": "numbers-02-1", "duration": 340, "correct": true}
	var attempt2: Dictionary = {"questionID": "numbers-02-2", "duration": 102, "correct": true}
	var attempt3: Dictionary = {"questionID": "numbers-02-3", "duration": 100, "correct": true}
	var output = submit_attempt("XKwVQ9EqJ7xjEhHoPr0A", [attempt1, attempt2, attempt3])
	yield(output, "completed")
	print("submit_attempts() completed")



func _on_test_button_button_up():
	var student_id1 = "test-student1"
	var student_id2 = "test-student2"
	var query = FirestoreQuery.new()
	query.from("Question_Attempt", false)
	query.where("studentID", FirestoreQuery.OPERATOR.EQUAL, student_id1, FirestoreQuery.OPERATOR.AND)
	query.where("studentID", FirestoreQuery.OPERATOR.EQUAL, student_id2)
	var task = Firebase.Firestore.query(query)
	var docs = yield(task, "task_finished")
	print(docs)

func _on_login_button_up():
	Firebase.Auth.login_with_email_and_password("test@maildrop.cc", "password")


func _on_get_last_level_attempted_button_up():
	var output = yield(get_last_level_attempted("test-student1", "numbers-tower"), "completed")
	print(output)
