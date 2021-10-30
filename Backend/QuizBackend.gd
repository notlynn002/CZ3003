extends Control

class_name QuizBackend

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Firebase.Auth.login_with_email_and_password("admin@gmail.com", "cz3003ssad")
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


static func create_quiz(quiz_tower_id: String, class_ids: Array, quiz_name: String, max_time: int, no_of_tries: int, publishing_date, questions: Array) -> String:
	"""Create a quiz and writes it to the database.
	
	Args:
		quiz_tower_id (String): Tower ID of the quiz tower.
		class_ids (Array[String]): List of class ID of that class that the quiz is assigned to.
		quiz_name (String): Quiz name.
		max_time (int): Maximum time that a student is allowed for the quiz, formatted as total seconds.
		no_of_tries (int): Maximum number of tries that a student is allowed for the quiz.
		publishing_date (Dictionary): Quiz publishing date in UTC time, formatted as a datetime Dictionary.
		questions (Array[Dictionary]): Quiz questions as Dictionary objects. Each question dictionary should contain the following fields:
			"qnContent" (String): Question content.
			"correctOption" (String): Question's correct option.
			"wrongOption1" (String): A wrong option.
			"wrongOption2" (String): A wrong option.
			"wrongOption3" (String): A wrong option.
	
	Returns:
		String: The quiz level ID of the new quiz.
	
	"""
	# Create quiz dictionary
	var quiz: Dictionary = {
		"towerID": quiz_tower_id,
		"levelDuration": max_time,
		"levelType": "quiz",
		"quizName": quiz_name,
		"attemptNo": no_of_tries,
		"publishingDate": publishing_date,
		"questions": questions
	}

	# Write quiz level to Level collection
	# Create quiz id
	var quiz_level_id: String = "quiz-" + quiz["quizName"].replace(" ", "-")
	# remove questions from quiz dict
	quiz.erase("questions")
	# write data to level collection
	var collection: FirestoreCollection = Firebase.Firestore.collection("Level")
	var task: FirestoreTask = collection.add(quiz_level_id, quiz)
	var doc = yield(task, "task_finished")
	if not doc is FirestoreDocument:
		return Error.raise_invalid_parameter_error("'%s' is already the name of an existing quiz" % quiz["quizName"])
	
	# Add questions
	var qn_data
	var qn_options
	collection = Firebase.Firestore.collection("Question")
	for question in questions:
		qn_options = [question["correctOption"], question["wrongOption1"], question["wrongOption2"], question["wrongOption3"]]
		qn_options.shuffle()
		qn_data = {
			"levelID": quiz_level_id,
			"questionBody": question["qnContent"],
			"questionOptions": qn_options,
			"questionSoln": question["correctOption"]
		}
		task = collection.add("", qn_data)
		yield(task, "task_finished")
	
	# Add quiz id to class
	# Check if class_id is valid
	collection = Firebase.Firestore.collection("Class")
	var quiz_list
	for class_id in class_ids:
		quiz_list = yield(get_quiz_ids_by_class(class_id), "completed")
		if not quiz_list is Array:
			Error.raise_invalid_parameter_error("'%s is not a valid class ID" % class_id)
			continue
		quiz_list.append(quiz_level_id)
		task = collection.update(class_id, {"quizList": quiz_list})
		yield(task, "task_finished")
	
	return quiz_level_id


static func delete_quiz(quiz_level_id: String, class_ids: Array):
	"""Delete a quiz and remove its data from the database
	
	Args:
		quiz_level_id (String): Level ID of the quiz
		class_ids (Array[String]): List of class ID of the class that the quiz was assigned to
	
	"""
	# Check if quiz level ID is valid
	var collection: FirestoreCollection = Firebase.Firestore.collection("Level")
	var task: FirestoreTask = collection.get(quiz_level_id)
	var doc = yield(task, "task_finished")
	if not doc is FirestoreDocument:
		Error.raise_invalid_parameter_error("'%s' is not a valid quiz level ID" % quiz_level_id)
		
	# Update class quiz list
	var quiz_list
	for class_id in class_ids:
		quiz_list = yield(get_quiz_ids_by_class(class_id), "completed")
		if not quiz_list is Array:
			Error.raise_invalid_parameter_error("'%s is not a valid class ID" % class_id)
			continue
		elif not quiz_level_id in quiz_list:
			Error.raise_invalid_parameter_error("The quiz with level ID '%s' is not assigned to the class with class ID '%s'" % [quiz_level_id, class_id])
			continue
		quiz_list.erase(quiz_level_id)
		collection = Firebase.Firestore.collection("Class")
		task = collection.update(class_id, {"quizList": quiz_list})
		yield(task, "task_finished")
	
	# Delete quiz level
	collection = Firebase.Firestore.collection("Level")
	task = collection.delete(quiz_level_id)
	yield(task, "task_finished")
	
	# Get question ids of quiz questions and then delete them
	var query: FirestoreQuery = FirestoreQuery.new()
	query.from("Question")
	query.where("levelID", FirestoreQuery.OPERATOR.EQUAL, quiz_level_id) 
	query.select([])
	task = Firebase.Firestore.query(query)
	var question_docs: Array = yield(task, "task_finished")
	collection = Firebase.Firestore.collection("Question")
	for question_doc in question_docs:
		task = collection.delete(question_doc.doc_name)
		yield(task, "task_finished")
 

static func _query_quiz_questions(quiz_level_id: String) -> Array:
	""" Get the questions for a quiz.
	
	Args:
		quiz_level_id (String): Level ID of the quiz.
		
	Returns:
		Array[FirestoreDocument]: The question documents.
		
	"""
	var query: FirestoreQuery = FirestoreQuery.new()
	query.from("Question")
	query.where("levelID", FirestoreQuery.OPERATOR.EQUAL, quiz_level_id) 
	var task: FirestoreTask = Firebase.Firestore.query(query)
	var question_docs: Array = yield(task, "task_finished")
	return question_docs
	

static func get_quiz(quiz_level_id: String) -> Dictionary:
	""" Get a quiz and its details.
	
	Args:
		quiz_level_id (String): Level ID of the quiz.
		
	Returns:
		Dictionary: The quiz as a dictionary.
			The Dictionary contains following keys-value pairs (all keys are Strings):
				towerID (String): Tower ID of the quiz tower.
				levelType (String): Fixed as 'quiz'.
				levelDuration (int): Maximum time that a student is allowed for the quiz, formatted as total seconds.
				quizName (String): Quiz name.
				attemptNo (int): Maximum number of tries that a student is allowed for the quiz.
				publishingDate (Dictionary): Quiz publishing date in UTC time, formatted as a datetime Dictionary.
				questions (Array[Dictionary]): Quiz questions as Dictionary objects. 
					Each Dictionary contains following keys-value pairs (all keys are Strings):
						questionID (String): Question ID.
						levelID (String): Quiz level ID.
						questionNo (int): Question number.
						questionBody (String): Question body.
						questionOptions (Array[String]): Question options.
						questionSoln (String): Question solution.
						questionExplanation (String): Question explanation.
		
	"""
	var quiz: Dictionary
	
	# Get quiz level data
	var collection: FirestoreCollection = Firebase.Firestore.collection("Level")
	var task: FirestoreTask = collection.get(quiz_level_id)
	var level_doc = yield(task, "task_finished")
	if not level_doc is FirestoreDocument:
		Error.raise_invalid_parameter_error("'%s' is not a valid quiz level ID" % quiz_level_id)
		return {}
	quiz = level_doc.doc_fields
	
	# Get quiz question data
	var question_docs: Array = yield(_query_quiz_questions(quiz_level_id), "completed")
	var question_dict: Dictionary
	var question_dicts = []	
	for question_doc in question_docs:
		question_dict = question_doc.doc_fields
		question_dict["questionID"] =  question_doc.doc_name
		question_dicts.append(question_dict)
	quiz["questions"] = question_dicts		
	
	return quiz 


static func get_quiz_ids_by_class(class_id: String) -> Array:
	""" Get the quiz level IDs for a class.
	
	Args:
		class_id (String): Class ID.
	
	Returns:
		Array[String]: The quiz level IDs as Strings.
	
	"""
	var collection: FirestoreCollection = Firebase.Firestore.collection("Class")
	var task: FirestoreTask = collection.get(class_id)
	var doc = yield(task, "task_finished")
	if not doc is FirestoreDocument:
		Error.raise_invalid_parameter_error("'%s is not a valid class ID" % class_id)
		return []
	return doc.doc_fields["quizList"]


static func get_quizzes_by_class(class_id: String) -> Array:
	""" Get quizzes and their details for a class
	
	Args:
		class_id (String): Class ID.
		
	Returns:
		Array[Dictionary]: The quizzes as Dictionary objects.
			Each Dictionary contains following keys-value pairs (all keys are Strings):
				towerID (String): Tower ID of the quiz tower.
				levelType (String): Fixed as 'quiz'.
				levelDuration (int): Maximum time that a student is allowed for the quiz, formatted as total seconds.
				quizName (String): Quiz name.
				attemptNo (int): Maximum number of tries that a student is allowed for the quiz.
				publishingDate (Dictionary): Quiz publishing date in UTC time, formatted as a datetime Dictionary.
				questions (Array[Dictionary]): Quiz questions as Dictionary objects. 
					Each Dictionary contains following keys-value pairs (all keys are Strings):
						questionID (String): Question ID.
						levelID (String): Quiz level ID.
						questionNo (int): Question number.
						questionBody (String): Question body.
						questionOptions (Array[String]): Question options.
						questionSoln (String): Question solution.
						questionExplanation (String): Question explanation.
		
	"""
	# Get quiz IDs for the class
	var quiz_ids = yield(get_quiz_ids_by_class(class_id), "completed")
	
	# Get quizzes
	var quiz: Dictionary
	var quizzes: Array = []
	for quiz_id in quiz_ids:
		quiz = yield(get_quiz(quiz_id), "completed")
		quizzes.append(quiz)
	
	quizzes.sort_custom(QuizSorter, "sort_chronological")
	return quizzes
	

static func _get_quiz_attempt_doc(student_id: String, quiz_level_id: String) -> FirestoreDocument:
	""" Get the document for a quiz attempt.
	
	Args:
		student_id (String): Student's user ID.
		quiz_leve_id (String): Quiz's level ID.
	
	Returns:
		FirestoreDocument: The quiz attempt document.
		
	"""
	var query: FirestoreQuery = FirestoreQuery.new()
	query.from("Quiz_Attempt", false)
	query.where("studentID", FirestoreQuery.OPERATOR.EQUAL, student_id, FirestoreQuery.OPERATOR.AND)
	query.where("quizID", FirestoreQuery.OPERATOR.EQUAL, quiz_level_id)
	var task: FirestoreTask = Firebase.Firestore.query(query)
	var docs = yield(task, "task_finished")
	if docs:
		return docs[0]
	else:
		return null
	
	
static func submit_quiz_attempt(student_id: String, quiz_level_id: String, total_time: int, question_attempts: Dictionary):
	""" Write a student's quiz attempts to the database.
	
	If the student has not attempted the quiz before, the student's first attempt will be written to the database.
	If the student has attempted the quiz before, the attempt number count in the student's quiz attempt will be incremented.
	
	Args:
		student_id (String): Student's user ID.
		quiz_level_id (String): Quiz's level ID.
		total_time (int): Time taken as total seconds.
		question_attempt (Dictionary): The question attempts as key-value pairs in a Dictionary.
			Key (String): Quiz question ID.
			Value (bool): true if the student got the question correct, false otherwise.
	
	"""
	# get quiz attempt
	var doc = yield(_get_quiz_attempt_doc(student_id, quiz_level_id), "completed")
	
	var coll: FirestoreCollection = Firebase.Firestore.collection("Quiz_Attempt")
	var task
	
	# quiz attempt exists, increment attempt number
	if doc:
		var attempt_no: int = doc.doc_fields["attemptNo"]
		attempt_no += 1
		task = coll.update(doc.doc_name, {"attemptNo": attempt_no})
		
	
	# quiz attempt does not exsits, create new attempt
	else:
		var attempt_id: String = "%s-%s" % [student_id, quiz_level_id]
		var attempt: Dictionary = {
			"studentID": student_id,
			"quizID": quiz_level_id,
			"duration": total_time,
			"questionAttempts": question_attempts,
			"attemptNo": 1
		}
		task = coll.add(attempt_id, attempt)
	
	yield(task, "task_finished")
	print("quiz result submitted!")

		
static func check_max_attempt_reached(student_id: String, quiz_level_id: String) -> bool:
	""" Check whether a student has reached the maximum allowed attempts for a quiz.
	
	Args:
		student_id (String): Student's user ID.
		quiz_leve_id (String): Quiz's level ID.
	
	Returns:
		bool/null: True if the student has reached the maximum allowed attempts.
			False if the student has not reached the maximum allowed attempts.
			Null if there is no such quiz in the database.
		
	"""
	# get quiz settings
	var coll: FirestoreCollection = Firebase.Firestore.collection("Level")
	var task: FirestoreTask = coll.get(quiz_level_id)
	var doc = yield(task, "task_finished")
	if not doc is FirestoreDocument:
		return null
	var max_attempt = doc.doc_fields["attemptNo"]
	
	doc = yield(_get_quiz_attempt_doc(student_id, quiz_level_id), "completed")
	# At least one attempt has been made
	if doc:
		var attempt_no = doc.doc_fields["attemptNo"]
		if attempt_no < max_attempt:
			return false
		else:
			return true
	else:
		return false
	
"""
static func update_quiz(quiz_level_id: String, quiz: Dictionary):
	# Check quiz for invalid fields
	#if Error.check_quiz(quiz, false) != OK:
	#	return Error.raise_invalid_parameter_error("'quiz' Dictionary has an invalid field")
	
	# Update quiz settings
	var new_questions: Array = quiz["questions"]
	quiz.erase("questions")
	var collection: FirestoreCollection = Firebase.Firestore.collection("Level")
	var task: FirestoreTask = collection.update(quiz_level_id, quiz)
	var doc = yield(task, "task_finished")
	if not doc is FirestoreDocument:
		return Error.raise_invalid_parameter_error("'quiz_level_id' argument is not a valid quiz level ID")
	
	# Get old questions
	var old_questions: Array = yield(_query_quiz_questions(quiz_level_id), "completed")
	var old_question_ids: Array
	for old_question in old_questions:
		old_question_ids.append(old_question.doc_name)
	# Update questions
	var new_question_id
	collection = Firebase.Firestore.collection("Question")
	for new_question in new_questions:
		# Update questions
		new_question_id = new_question.get("questionID")
		if new_question_id != null:
			new_question.erase("questionID")
			task = collection.update(new_question_id, new_question)
			old_question_ids.erase(new_question_id)
		else:
			new_question["levelID"] = quiz_level_id
			task = collection.add("", new_question)
		yield(task, "task_finished")
	# Delete remaining old questions
	for old_question_id in old_question_ids:
		task = collection.delete(old_question_id)
		yield(task, "task_finished")
"""


func _on_test_button_up():
	#var output = yield(submit_quiz_attempt("student1", "quiz-hard-test-:(", {"qn1": true, "qn2": false}), "completed")
	var output = yield(check_max_attempt_reached("student1", "a"), "completed")
	print(output)


func _on_create_quiz_button_up():
	var qn1 = {"questionBody": "4 + 2 = ?", "questionSoln": "6", "questionExplanation": "count", "questionOptions": ["1", "2", "3", "6"]}
	var qn2 = {"questionBody": "5 x 2 = ?", "questionSoln": "10", "questionExplanation": "count", "questionOptions": ["1", "2", "3", "10"]}
	var qn3 = {"questionBody": "4 - 2 = ?", "questionSoln": "2", "questionExplanation": "count", "questionOptions": ["1", "2", "3", "6"]}
	var class_ids = ["Class-A", "Class-C"]
	var publishing_date1 = Datetime.get_datetime_dict(2021, 11, 16, 10, 30, 0, true)
	var output = yield(
		create_quiz("quiz-tower", class_ids, "quiz 4", 600, 3, publishing_date1, [qn1.duplicate(true), qn2.duplicate(true), qn3.duplicate(true)]), 
		"completed"
		)
	print(output)
	print("create quiz done")


func _on_delete_quiz_button_up():
	var class_ids = ["Class-A", "Class-C"]
	for quiz_level_id in ["quiz-quiz-4"]:
		var output = delete_quiz(quiz_level_id, class_ids)
		output = yield(output, "completed")
		print("deleted %s" % quiz_level_id)
	print("delete quiz done")


func _on_get_quizzes_by_class_button_up():
	var class_id = "test-class-2"
	var output = get_quizzes_by_class(class_id)
	output = yield(output, "completed")
	for e in output:
		print(e["quizName"])
		print(e["publishingDate"])
		print()
	print("done")

"""
func _on_update_quiz_button_up():
	var quiz_id = "quiz-quiz-1"
	var quiz = yield(get_quiz(quiz_id), "completed")
	var questions = quiz["questions"]
	questions[0]["questionExplanation"] = "use calculator"
	var qn4 = {"questionBody": "4 + 1 = ?", "questionSoln": "5", "questionExplanation": "take this L", "questionOptions": ["1", "2", "3", "5"]}
	questions.append(qn4)
	quiz["questions"] = questions
	yield(update_quiz(quiz_id, quiz), "completed")
	print("update done")
"""
