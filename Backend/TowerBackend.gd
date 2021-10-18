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
		i.doc_fields['questionID'] = i.doc_name
		res.append(i.doc_fields)
		
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
	
	
static func _query_level_attempts(student_id: String, level_id: String, type: String, correct: bool = false) -> Array:
	# Get question ids of question in level
	var query = FirestoreQuery.new()
	query.from("Question", false)
	query.where("levelID", FirestoreQuery.OPERATOR.EQUAL, level_id)
	var task: FirestoreTask = Firebase.Firestore.query(query)
	var question_docs: Array = yield(task, "task_finished") # Array<FirestoreDocument>
	var question_ids: Array = []
	for doc in question_docs:
		question_ids.append(doc.doc_name)
	
	# Query question attempt documents
	query = FirestoreQuery.new()
	query.from("Question_Attempt")
	query.where("studentID", FirestoreQuery.OPERATOR.EQUAL, student_id, FirestoreQuery.OPERATOR.AND)
	query.where("questionID", FirestoreQuery.OPERATOR.IN, question_ids, FirestoreQuery.OPERATOR.AND)
	if correct:
		query.where("type", FirestoreQuery.OPERATOR.EQUAL, type, FirestoreQuery.OPERATOR.AND)
		query.where("correct", FirestoreQuery.OPERATOR.EQUAL, true)
	else:
		query.where("type", FirestoreQuery.OPERATOR.EQUAL, type)
	task = Firebase.Firestore.query(query)
	return yield(task, "task_finished")

	
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
	# Query question attempt documents
	var attempt_docs = yield(_query_level_attempts(student_id, level_id, type), "completed")

	# Get question attempt fields
	var attempts: Array = []
	for doc in attempt_docs:
		attempts.append(doc.doc_fields)
	
	return attempts	
	
	
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
	var query: FirestoreQuery = FirestoreQuery.new()
	query.from("Question_Attempt")
	query.where("studentID", FirestoreQuery.OPERATOR.EQUAL, student_id, FirestoreQuery.OPERATOR.AND)
	query.where("questionID", FirestoreQuery.OPERATOR.EQUAL, question_id, FirestoreQuery.OPERATOR.AND)
	query.where("type", FirestoreQuery.OPERATOR.EQUAL, "first")
	var task = Firebase.Firestore.query(query)
	var result = yield(task, "task_finished")
	if result:
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
	# Calculate old score and timing
	var old_score: int = 0
	var old_timing: int = 0
	for attempt in old_best_attempts:
		old_score += int(attempt["correct"])
		old_timing += attempt["duration"]
	
	# calculate new score and timing
	var new_score: int = 0
	var new_timing: int = 0
	for attempt in new_best_attempts:
		new_score += int(attempt["correct"])
		new_timing += attempt["duration"]
	
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


static func get_correct_for_tower_by_student(student_id: String, tower_id: String):
	""" Get the number of questions that a student got correct for each level in a tower.
	
	Args:
		student_id (String): Student's user ID.
		tower_id (String): Tower ID.
		
	Returns:
		Array[int]: Each int in the Array represents the number of questions a student got correct of a particular level.
			The numbers of correct questions are ordered according to level number. Only 
		
	"""
	# get level ids
	var level_ids: Array = yield(get_level_for_tower(tower_id), "completed")	
	
	# get attempts
	var correct_nos: Array = []
	for level_id in level_ids:
		var attempt_docs: Array = yield(_query_level_attempts(student_id, level_id, "best"), "completed")
		
		# if reached highest level attempted, break out of loop
		if not attempt_docs:
			break
		
		level_ids.erase(level_id)
		
		# count number of correct for level
		var correct_no: int = 0
		for attempt_doc in attempt_docs:
			if attempt_doc.doc_fields["correct"]:
				correct_no += 1
		correct_nos.append(correct_no)
	
	# add zeros for non-attempted levels
	for level_id in level_ids:
		correct_nos.append(0)
	
	return correct_nos


static func get_level_display_info(student_id: String, tower_id: String) -> Dictionary:
	""" Get the data needed for the level selection page.
	
	Args:
		student_id (String): Student's user ID.
		tower_id (String): Tower ID.
		
	Returns:
		Dictionary: The data needed for the page. The dictionary includes:
			"last_level" (int): the last level attempted by the student in the tower
			"correct_nos" (Array[int]): Array of ints representing the number of questions that the student got correct for each level.
	
	"""
	# get number of levels
	var query: FirestoreQuery = FirestoreQuery.new()
	query.from("Level")
	query.where("towerID", FirestoreQuery.OPERATOR.EQUAL, tower_id)
	query.order_by("level")
	var task: FirestoreTask = Firebase.Firestore.query(query)
	var docs: Array = yield(task, "task_finished")
	var total_levels: int = docs.size()
	
	# get attempt docs
	query = FirestoreQuery.new()
	query.from("Question_Attempt", false)
	query.where("studentID", FirestoreQuery.OPERATOR.EQUAL, student_id, FirestoreQuery.OPERATOR.AND)
	query.where("towerID", FirestoreQuery.OPERATOR.EQUAL, tower_id, FirestoreQuery.OPERATOR.AND)
	query.where("type", FirestoreQuery.OPERATOR.EQUAL, "best")
	task = Firebase.Firestore.query(query)
	docs = yield(task, "task_finished")
	
	var curr_level: int = 1
	var curr_score: int = 0
	var correct_nos: Array = []
	for doc in docs:
		var qn_id: String = doc.doc_fields["questionID"]
		var level_no: int = int(qn_id.substr(qn_id.length()-4, 2))
		
		# still on the same level, increment score
		if curr_level == level_no:
			curr_score += int(doc.doc_fields["correct"])
		
		# on a new level, store previous score and change curr_level
		else:
			# store previous score
			correct_nos.append(curr_score)
			# restart score
			curr_score = int(doc.doc_fields["correct"])
			# chane curr_level to new level
			curr_level = level_no
	correct_nos.append(curr_score)
	
	# append zeros to correct_nos for levels that were not attempted
	for i in range(curr_level, total_levels):
		correct_nos.append(0)
	
	# return last level attempted and list of correct numbers
	return {
		"last_level": curr_level,
		"correct_nos": correct_nos
	}


func _on_Get_level_attempt_button_up():
	var output = yield(get_level_attempt("test-student1", "numbers-01", "first"), "completed")
	print(output)


func _on_sumbit_attempt_button_up():
	var attempt1: Dictionary = {"questionID": "numbers-04-1", "duration": 100, "correct": true}
	var attempt2: Dictionary = {"questionID": "numbers-04-2", "duration": 102, "correct": true}
	var attempt3: Dictionary = {"questionID": "numbers-04-3", "duration": 100, "correct": true}
	var output = submit_attempt("NjKMDRdI7Ih9SF3TDxr1zRimtZH2", [attempt1, attempt2, attempt3])
	yield(output, "completed")
	print("submit_attempts() completed")



func _on_test_button_button_up():
	print(OS.get_datetime())
	var output = yield(get_level_display_info("NjKMDRdI7Ih9SF3TDxr1zRimtZH2", "numbers-tower"), "completed")
	print(output)
	print(OS.get_datetime())
	

func _on_login_button_up():
	Firebase.Auth.login_with_email_and_password("test@maildrop.cc", "password")


func _on_get_last_level_attempted_button_up():
	var output = yield(get_last_level_attempted("test-student1", "numbers-tower"), "completed")
	print(output)



#output format - sorted list [{"name": String, "highestLevel", int, "totalCorrect" int, "timing" int}]
static func get_leaderboard(towerID):
	# get all the levelIDs of the boss levels in this tower
	var query : FirestoreQuery = FirestoreQuery.new()
	query.from('Level')
	query.where('towerID', FirestoreQuery.OPERATOR.EQUAL, towerID, FirestoreQuery.OPERATOR.AND)
	query.where('levelType', FirestoreQuery.OPERATOR.EQUAL,"boss")
	query.select([])
	var query_task : FirestoreTask = Firebase.Firestore.query(query)
	var result = yield(query_task, 'task_finished')
	#print(result)
	
	var attempts = []
	for i in result:
		#var q_query : FirestoreQuery = FirestoreQuery.new()
		#q_query.from('Question')
		#q_query.where('levelID', FirestoreQuery.OPERATOR.EQUAL, i.doc_name)
		#q_query.select([])
		#var qn_query : FirestoreTask = Firebase.Firestore.query(q_query)
		#var qns = yield(qn_query, 'task_finished')
		#print(i.doc_name)
		#print("____________________________________")
		#print(qns)
		for qnNo in range(1,6):
			var qn = i.doc_name +"-" + str(qnNo)
			var a_query : FirestoreQuery = FirestoreQuery.new()
			a_query.from('Question_Attempt')
			a_query.where('questionID', FirestoreQuery.OPERATOR.EQUAL, qn, FirestoreQuery.OPERATOR.AND)
			a_query.where('type', FirestoreQuery.OPERATOR.EQUAL, "first")
			
			var attempt_query : FirestoreTask = Firebase.Firestore.query(a_query)
			var qn_attempts = yield(attempt_query, 'task_finished')
			for att in qn_attempts:
				attempts.append(att.doc_fields)
			
	#print(attempts)
	
	var student_dict = {}
	# {name: , totalCorrect: , timing , highestLevel: }
	for attempt in attempts:
		var studentID = attempt.studentID
		var level = int(attempt.questionID.split("-")[1])
		
		if studentID in student_dict:
			if attempt.correct:
				student_dict[studentID]["totalCorrect"] += 1
				student_dict[studentID]["timing"] += attempt.duration
			
			student_dict[studentID]["highestLevel"] = max(student_dict[studentID].highestLevel, level)
				
		else:
			var user = yield(ProfileBackend.getUser(attempt.studentID), "completed")
			
			if user != null:
				if attempt.correct:
					student_dict[studentID] = {"name": user.name, "highestLevel": level, "totalCorrect": 1, "timing": attempt.duration}
				else:
					student_dict[studentID] = {"name": user.name, "highestLevel": level, "totalCorrect": 0, "timing": 0}
	
	var rankings = student_dict.values()
	
	
	#rankings.append({"name": "earth", "highestLevel": 5, "totalCorrect": 5, "timing": 200})
	#rankings.append({"name": "moon", "highestLevel": 15, "totalCorrect": 0, "timing": 0})
	#rankings.append({"name": "sun", "highestLevel": 10, "totalCorrect": 4, "timing": 100})
	#rankings.append({"name": "star", "highestLevel": 10, "totalCorrect": 5, "timing": 200})
	
	rankings.sort_custom(LeaderboardSorter, "sort_rankings_order")
	
	return rankings
	

	


func _on_getLeaderboard_button_up():
	get_leaderboard('numbers-tower')
	pass # Replace with function body.
	


func _on_submit_multiple_level_attempts_button_up():
	var student_id = "iZKcmDRrSdc0zn8vU6ZnxaEpPGH2"
	var tower_id = "numbers-tower"
	var max_level = 10
	
	# get level ids 
	var level_ids = yield(get_level_for_tower(tower_id), "completed")
	
	# For each level, submit attempts
	for i in range(max_level):
		# get question docs
		var level_id = level_ids[i]
		var query = FirestoreQuery.new()
		query.from("Question")
		query.where("levelID", FirestoreQuery.OPERATOR.EQUAL, level_id)
		var task = Firebase.Firestore.query(query)
		var docs = yield(task, "task_finished")
		
		# for each qn in level, create qn attempt
		var attempts = []
		for doc in docs:
			var attempt = {
				"questionID": doc.doc_name,
				"duration": randi()%120+1, # random int between 1 and 120 (2 mins)
				"correct": bool(randi()%2) # random bool
			}
			attempts.append(attempt)
		
		# submit attempts for level
		yield(_add_first_attempts(student_id, attempts), "completed")
	
	print("done")

