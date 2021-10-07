extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Firebase.Auth.login_with_email_and_password("test@maildrop.cc", "password")
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func create_quiz(quiz_tower_id: String, class_id: String, quiz_name: String, max_time: int, no_of_tries: int, publishing_date: Dictionary, questions: Array):
	"""Create a quiz and writes it to the database.
	
	Args:
		quiz_tower_id (String): Tower ID of the quiz tower.
		class_id (String): Class ID of that class that the quiz is assigned to.
		quiz_name (String): Quiz name.
		max_time (int): Maximum time that a student is allowed for the quiz, formatted as total seconds.
		no_of_tries (int): Maximum number of tries that a student is allowed for the quiz.
		publishing_date (Dictionary): Quiz publishing date in UTC time, formatted as a datetime Dictionary.
		questions (Array[Dictionary]): Quiz questions as Dictionary objects.
			All Dictionary keys should be Strings.
			Each Dictionary should contains following keys-value pairs:
				questionNo (int): Question number.
				questionBody (String): Question body.
				questionOptions (Array[String]): Question options.
				questionSoln (String): Question solution.
				questionExplanation (String): Question explanation.
	
	Raises:
		ERR_INVALID_PARAMETER: If a parameter has an invalid value or if a quiz has the same name as an existing quiz (case sensitive).
	
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
	# Check quiz fields
	if $error.check_quiz(quiz, false) != OK:
		return $error.raise_invalid_parameter_error("Invalid quiz argument passed.")
		
	# Check if class_id is valid
	var collection: FirestoreCollection = Firebase.Firestore.collection("Class")
	var task: FirestoreTask = collection.get(class_id)
	var class_doc = yield(task, "task_finished")
	if not class_doc is FirestoreDocument:
		return $error.raise_invalid_parameter_error("'class_id' argument is invalid")
	
	# Write quiz level to Level collection
	# Create quiz id
	var quiz_level_id: String = quiz["quizName"].replace(",", " ") + "-quiz"
	# remove questions from quiz dict
	quiz.erase("questions")
	# write data to level collection
	collection = Firebase.Firestore.collection("Level")
	task = collection.add(quiz_level_id, quiz)
	var doc: FirestoreDocument = yield(task, "task_finished")
	
	# Add questions
	collection = Firebase.Firestore.collection("Question")
	var quiz_question_id: String
	for question in questions:
		quiz_question_id = quiz_level_id + question["questionNo"]
		question["levelID"] = quiz_level_id
		task = collection.add(quiz_question_id, question)
		yield(task, "task_finished")
	
	# Add quiz id to class
	collection = Firebase.Firestore.collection("Class")
	var quiz_list = class_doc.doc_fields["quizList"]
	quiz_list.append(quiz_level_id)
	task = collection.update(class_id, {"quizList": quiz_list})
	yield(task, "task_finished")


func delete_quiz(quiz_level_id: String, class_id: String):
	"""Delete a quiz and remove its data from the database
	
	Args:
		quiz_level_id (String): Level ID of the quiz
		class_id (String): Class ID of the class that the quiz was assigned to
	
	Raises:
		ERR_INVALID_PARAMETER: If the quiz level ID is invalid, the class ID is invalid, or the class does not contaion the quiz.
	
	"""
	# Check if quiz level ID is valid
	var collection: FirestoreCollection = Firebase.Firestore.collection("Level")
	var task: FirestoreTask = collection.get(quiz_level_id)
	var doc = yield(task, "task_finished")
	if not doc is FirestoreDocument:
		return $error.raise_invalid_parameter_error("'%s' is not a valid quiz level ID" % quiz_level_id)
		
	# Update class quiz list
	var quiz_list = yield(get_quiz_ids_by_class(class_id), "completed")
	if not quiz_list is Array:
		return $error.raise_invalid_parameter_error("'%s is not a valid class ID" % class_id)
	elif not quiz_level_id in quiz_list:
		return $error.raise_invalid_parameter_error("The quiz with level ID '%s' is not assigned to the class with class ID '%s'" % [quiz_level_id, class_id])
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
 

func _query_quiz_questions(quiz_level_id: String) -> Array:
	""" Get the questions for a quiz.
	
	Args:
		quiz_level_id (String): Level ID of the quiz.
		
	Returns:
		Array[FirestoreDocument]: The question documents.
		
	"""
	var query: FirestoreQuery = FirestoreQuery.new()
	query.from("Question")
	query.where("levelID", FirestoreQuery.OPERATOR.EQUAL, quiz_level_id) 
	query.order_by("questionNo")
	var task: FirestoreTask = Firebase.Firestore.query(query)
	var question_docs: Array = yield(task, "task_finished")
	return question_docs
	

func get_quiz(quiz_level_id: String) -> Dictionary:
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
	
	Raises:
		ERR_INVALID_PARAMETER: If quiz level ID is invalid.
		
	"""
	var quiz: Dictionary
	
	# Get quiz level data
	var collection: FirestoreCollection = Firebase.Firestore.collection("Level")
	var task: FirestoreTask = collection.get(quiz_level_id)
	var level_doc = yield(task, "task_finished")
	if not level_doc is FirestoreDocument:
		return $error.raise_invalid_parameter_error("'%s' is not a valid quiz level ID" % quiz_level_id)
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


func get_quiz_ids_by_class(class_id: String) -> Array:
	""" Get the quiz level IDs for a class.
	
	Args:
		class_id (String): Class ID.
	
	Returns:
		Array[String]: The quiz level IDs as Strings.
	
	Raises:
		ERR_INVALID_PARAMETER: If the class ID is invalid.
	
	"""
	var collection: FirestoreCollection = Firebase.Firestore.collection("Class")
	var task: FirestoreTask = collection.get(class_id)
	var doc = yield(task, "task_finished")
	if not doc is FirestoreDocument:
		return $error.raise_invalid_parameter_error("'%s is not a valid class ID" % class_id)
	return doc.doc_fields["quizList"]


func get_quizzes_by_class(class_id: String) -> Array:
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
	
	Raises:
		ERR_INVALID_PARAMETER: If class ID is invalid.
		
	"""
	# Get quiz IDs for the class
	var quiz_ids = yield(get_quiz_ids_by_class(class_id), "completed")
	if not quiz_ids is Array:
		return $error.raise_invalid_parameter_error("'%s is not a valid class ID" % class_id)
	
	# Get quizzes
	var quiz: Dictionary
	var quizzes: Array = []
	for quiz_id in quiz_ids:
		quiz = yield(get_quiz(quiz_id), "completed")
		quizzes.append(quiz)
	
	quizzes.sort_custom($sorter.QuizSorter, "sort_chronological")
	return quizzes
	
	
func update_quiz(quiz_level_id: String, quiz: Dictionary):
	# Check quiz for invalid fields
	if $error.check_quiz(quiz) != OK:
		return $error.raise_invalid_parameter_error("'quiz' Dictionary has an invalid field")
	
	# Update quiz settings
	var new_questions: Array = quiz["questions"]
	quiz.erase("questions")
	var collection: FirestoreCollection = Firebase.Firestore.collection("Level")
	var task: FirestoreTask = collection.update(quiz_level_id, quiz)
	var doc = yield(task, "task_finished")
	if not doc is FirestoreDocument:
		return $error.raise_invalid_parameter_error("'quiz_level_id' argument is not a valid quiz level ID")
	
	# Get old questions
	var old_question_ids: Array
	for old_question in _query_quiz_questions(quiz_level_id):
		old_question_ids.append(old_question.doc_name)
	# Update questions
	var new_question_id: String
	collection = Firebase.Firestore.collection("Question")
	for new_question in new_questions:
		new_question_id = new_question["questionID"]
		new_question.erase("questionID")
		# Update existing questions
		if new_question_id in old_question_ids:
			task = collection.update(new_question_id, new_question)
			yield(task, "task_finished")
			old_question_ids.erase(new_question_id)
		# Add new questions
		else:
			task = collection.add(new_question_id, new_question)
			yield(task, "task_finished")
	# Delete remaining old questions
	for old_question_id in old_question_ids:
		task = collection.delete(old_question_id)
		yield(task, "task_finished")


func _on_test_button_up():
	var collection = Firebase.Firestore.collection("Level")
	var task = collection.add("test", {"test1": "test1"})
	var output = yield(task, "task_finished")
	print(output)
	"""
	var temp1 = Firebase.Firestore.collection("Level")
	var temp2 = temp1.get("a8tIZLze9Jp8h8kmEfuJ")
	var temp3 = yield(temp2, "task_finished")
	print(temp3)
	print("done")
	"""


func _on_create_quiz_button_up():
	var qn1 = {"questionNo": 1, "questionBody": "4 + 2 = ?", "questionSoln": "6", "questionExplanation": "count", "questionOptions": ["1", "2", "3", "6"]}
	var qn2 = {"questionNo": 2, "questionBody": "5 x 2 = ?", "questionSoln": "10", "questionExplanation": "count", "questionOptions": ["1", "2", "3", "10"]}
	var qn3 = {"questionNo": 3, "questionBody": "4 - 2 = ?", "questionSoln": "2", "questionExplanation": "count", "questionOptions": ["1", "2", "3", "6"]}
	var class_id = "7UqkzOmQq0LeNJVbgN6r"
	# 10.30 am in sgt
	var publishing_date1 = {"year": 2021, "month": 11, "day": 16, "hour": 2, "minute": 30, "second": 0}
	var publishing_date2 = {"year": 2021, "month": 11, "day": 11, "hour": 2, "minute": 30, "second": 0}
	var publishing_date3 = {"year": 2021, "month": 10, "day": 11, "hour": 2, "minute": 30, "second": 0}
	var output = yield(
		create_quiz("quiz-tower", class_id, "quiz 1", 600, 3, publishing_date1, [qn1, qn2, qn3]), 
		"completed"
		)
	print(output)
	print("create quiz 1 done")
	create_quiz("quiz-tower", class_id, "quiz 2", 600, 3, publishing_date2, [qn1, qn2, qn3])
	"""
	output = yield(
		create_quiz("quiz-tower", class_id, "quiz 2", 600, 3, publishing_date2, [qn1, qn2, qn3]), 
		"completed"
		)
	print(output)
	print("create quiz 2 done")
	output = yield(
		create_quiz("quiz-tower", class_id, "quiz 3", 600, 3, publishing_date1, [qn1, qn2, qn3]), 
		"completed"
		)
	print(output)
	print("create quiz 3 done")
	output = yield(
		create_quiz("quiz-tower", class_id, "quiz 4", 600, 3, publishing_date3, [qn1, qn2, qn3]), 
		"completed"
		)
	print(output)
	print("create quiz 4 done")
	"""
	print("create quiz done")


func _on_delete_quiz_button_up():
	var quiz_level_id = "HfQ3oQ9icuBemxNeVz0V"
	var class_id = "7UqkzOmQq0LeNJVbgN6r"
	var output = delete_quiz(quiz_level_id, class_id)
	output = yield(output, "completed")
	print(output)
	print("delete quiz done")


func _on_get_quizzes_by_class_button_up():
	var class_id = "7UqkzOmQq0LeNJVbgN6r"
	var output = get_quizzes_by_class(class_id)
	output = yield(output, "completed")
	for e in output:
		print(e["quizName"])
		print(e["publishingDate"])
		print()
	print("done")


func _on_update_quiz_button_up():
	pass # Replace with function body.
