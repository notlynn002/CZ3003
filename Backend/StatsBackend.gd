extends Control

class_name StatsBackend

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Firebase.Auth.login_with_email_and_password("admin@gmail.com", "cz3003ssad")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

static func get_class_ids_and_names(teacher_id: String) -> Dictionary:
	""" Get class IDs and names of classes for a specific teacher.
	
	Args:
		teacher_id (String): User ID of the teacher.
		
	Returns:
		Dictionary: The class names and IDs as key-value pairs in a Dictionary.
			Key (String): Class name.
			Value (String): Class ID.
	
	"""
	# query classes
	var query: FirestoreQuery = FirestoreQuery.new()
	query.from("Class")
	query.where("teacherID", FirestoreQuery.OPERATOR.EQUAL, teacher_id)
	query.order_by("className")
	var task: FirestoreTask = Firebase.Firestore.query(query)
	var docs: Array = yield(task, "task_finished")
	
	# get class names and ids
	var class_info: Dictionary = {}
	for doc in docs:
		class_info[doc.doc_fields["className"]] = doc.doc_name
		
	return class_info


static func get_student_ids_and_names(class_ids: Array) -> Dictionary:
	""" Gets the names and IDs of all students in specific classes.
	
	Args:
		class_ids (Array[String]): An Array of class IDs.
		
	Returns:
		Dictionary: Names and IDs of the students as key-value pairs in a Dictionary.
			Key (String): Student name.
			Value (String): Student ID.
	
	"""
	var student_info: Dictionary = {}
	
	for class_id in class_ids:
		var query: FirestoreQuery = FirestoreQuery.new()
		query.from("User", false)
		query.where("classId", FirestoreQuery.OPERATOR.EQUAL, class_id)
		var task: FirestoreTask = Firebase.Firestore.query(query)
		var docs: Array = yield(task, "task_finished")
	
	# get student ids and names
		for doc in docs:
			student_info[doc.doc_fields["name"]] = doc.doc_name
	
	return student_info


static func get_tower_ids_and_names() -> Dictionary:
	""" Get tower IDs and names of all towers.
		
	Returns:
		Dictionary: The tower names and IDs as key-value pairs in a Dictionary.
			Key: Tower name.
			Value: Tower ID.
	
	"""
	# get tower docs
	var query: FirestoreQuery = FirestoreQuery.new()
	query.from("Tower")
	var task: FirestoreTask = Firebase.Firestore.query(query)
	var docs: Array = yield(task, "task_finished")
	
	# get tower names and ids
	var tower_info: Dictionary = {}
	for doc in docs:
		var tower_name: String = "%s Tower" % doc.doc_fields["topic"].capitalize()
		tower_info[tower_name] = doc.doc_name
	
	return tower_info 
	

static func _get_boss_level_ids_and_names(tower_id: String) -> Dictionary:
	""" Gets the level numbers and level IDs for boss levels in a specific tower.
	
	Args:
		tower_id (String): Tower ID.
	
	Returns:
		Dictionary: Level numbers and IDs of the boss levels as key-value pairs in a Dictionary.
			Key (int): Level number.
			Value (String): Level ID.
	
	"""
	# Get all level ids
	var level_ids = yield(TowerBackend.get_level_for_tower(tower_id), "completed")
	
	# Get boss level ids
	var curr_level = 5
	var boss_level_ids = {}
	while curr_level <= level_ids.size():
		var level_name = "Level %d" % curr_level
		boss_level_ids[level_name] = level_ids[curr_level-1]
		curr_level  += 5
	
	return boss_level_ids


static func _get_quiz_ids_and_names(class_ids: Array) -> Dictionary:
	""" Get level IDs and names of quizzes for a few classes.
	
	Args:
		class_ids (Array[String]): An Array of class IDs.
		
	Returns:
		Dictionary: The student names and IDs as key-value pairs in a Dictionary.
			Key (String): Student name.
			Value (String): Student ID.
	
	"""
	var collection: FirestoreCollection = Firebase.Firestore.collection("Level")
	var quiz_info: Dictionary = {}
	for class_id in class_ids:
		var class_quiz_ids = yield(QuizBackend.get_quiz_ids_by_class(class_id), "completed")
		# if class does not exist, skip it
		if not class_quiz_ids is Array:
			continue
		
		for id in class_quiz_ids:
			if not quiz_info.has(id):
				# get quiz name
				var task: FirestoreTask = collection.get(id)
				var doc = yield(task, "task_finished")
				quiz_info[doc.doc_fields["quizName"]] = id
	return quiz_info
				

static func get_level_ids_and_names(tower_id: String, class_ids: Array = []) -> Dictionary:
	""" Get level IDs and names for a tower.
	
	If the tower is a game tower, the level IDs and names of its boss levels will be returned.
	If the tower is the quiz tower, the level IDs and names of quizzes corresponding to the classes will be returned.
	
	Args:
		tower_id (String): Tower ID.
		class_ids (Array[String], optional): An Array of class IDs for the quiz tower.
		
	Returns:
		Dictionary: The level names and IDs as key-value pairs in a Dictionary.
			Key (String): Level name.
			Value (String): Level ID.
	
	"""
	if tower_id == "quiz-tower":
		return yield(_get_quiz_ids_and_names(class_ids), "completed")
	else:
		return yield(_get_boss_level_ids_and_names(tower_id), "completed")


static func _query_questions_by_level(level_id: String) -> Array:
	""" Query the Firestore documents of questions in a level.
	
	Args:
		level_id (String): Level ID.
		
	Returns:
		Array[FirestoreDocument]: The documents of the questions.
	
	"""
	var query: FirestoreQuery = FirestoreQuery.new()
	query.from("Question")
	query.where("levelID", FirestoreQuery.OPERATOR.EQUAL, level_id)
	var task: FirestoreTask = Firebase.Firestore.query(query)
	var docs: Array = yield(task, "task_finished")
	return docs


static func get_tower_stats_by_class(tower_id: String, class_ids: Array) -> Array:
	""" Get statistics for the boss levels in a game tower, for students in specified classes.
	
	This function can only be used for game towers.
	Passing in the quiz tower ID returns an empty list.
	
	Args:
		tower_id (String): Game tower ID.
		class_ids(Array[String]): An Array of class IDs.
		
	Returns:
		Array[Dictionary]: Returns an Array of statistics for each student as Dictionaries. Each Dictionary contains:
			"student_name" (String): Student's name.
			"max_level" (int): Last level attempted by student for the tower.
			"avg_score" (float): Student's average score for attempted boss levels in the tower.
			"avg_timing" (float): Student's average timing for attempted boss levels in the tower. Timing is expressed as total seconds.
	
	"""
	# this function cannot be used for quiz tower
	# passing in quiz tower will crash the program, so a check is performed
	if tower_id == "quiz-tower":
		return []
	
	var student_info: Dictionary = yield(get_student_ids_and_names(class_ids), "completed")
	# get boss levels
	var level_info: Dictionary = yield(_get_boss_level_ids_and_names(tower_id), "completed")
	
	var stats: Array = []
	for student_name in student_info.keys():
		var student_id: String = student_info[student_name]
		
		# Get max level
		var max_level: int = yield(TowerBackend.get_last_level_attempted(student_id, tower_id), "completed")
		
		# Get average score and timing
		var avg_score: float = 0.0
		var avg_timing: float = 0.0
		var attempted_levels: int = max_level / 5 # number of boss levels attempted
		var level_ids: Array = level_info.values()
		for i in range(attempted_levels):
			var level_id = level_ids[i]
			
			# For each level, get level score and timing
			var level_attempts = yield(TowerBackend.get_level_attempt(student_id, level_id, "first"), "completed")
			# Check if all questions in the level were completed
			var level_completed: bool = true if (level_attempts.size() == 5) else false
			
			# get scores and timings for the level
			var level_score: float = 0.0
			# if level is not completed, level timing will be set to the maximum
			var level_timing: float = 0.0 if level_completed else 600
			for attempt in level_attempts:
				if attempt["correct"]:
					level_score += 1.0
				if level_completed:
					level_timing += attempt["duration"]
					
			# sum up scores and timings for each quiz
			avg_score += level_score
			avg_timing += level_timing
			
		# calculate average score and timing
		if attempted_levels != 0:
			avg_score /= attempted_levels
			avg_timing /= attempted_levels
		
		# format student's stats as a dict and add it to the list
		var student_stats = {
			"student_name" : student_name, 
			"max_level": max_level, 
			"avg_score": avg_score, 
			"avg_time": avg_timing
		}
		stats.append(student_stats)
		
	return stats


static func get_level_stats_by_class(level_id: String, class_ids: Array) -> Array:
	""" Get statistics for a level for students in specified classes.
	
	This function can only be used for both game boss levels and quiz levels.
	
	Args:
		level_id (String): Level ID.
		class_ids(Array[String]): An Array of class IDs.
		
	Returns:
		Array[Dictionary]: Returns an Array of statistics for each question in the level as Dictionaries. Each Dictionary contains:
			"qn_content" (String): Question content.
			"attempt_percent" (float): Percentage of students who attempted the question.
			"correct_percent" (float): Out of the students who attempted the question, the percentage of them that got the question correct.
			"avg_timing" (float): Average timing of students who attempted the question. Timing is expressed as total seconds.
	
	"""
	var student_info: Dictionary = yield(get_student_ids_and_names(class_ids), "completed")
	var student_ids: Array = student_info.values()
	
	# get questions in level
	var docs: Array = yield(_query_questions_by_level(level_id), "completed")
	
	var stats: Array = []
	# get stats for each question
	for doc in docs:
		var qn_id = doc.doc_name
		
		# get question content
		var qn_content = doc.doc_fields["questionBody"]
		
		# query all attempts for this question
		var query: FirestoreQuery = FirestoreQuery.new()
		query.from("Question_Attempt")
		query.where("questionID", FirestoreQuery.OPERATOR.EQUAL, qn_id)
		var task: FirestoreTask = Firebase.Firestore.query(query)
		var attempts = yield(task, "task_finished")

		# count number of attempted, correct and total time
		var attempted_count: int = 0
		var correct_count: int = 0
		var total_time: int = 0
		for attempt in attempts:
			if (attempt.doc_fields["studentID"] in student_ids) and (attempt.doc_fields["type"] == "first"):
				total_time += attempt.doc_fields["duration"]
				attempted_count += 1
				if attempt.doc_fields["correct"]:
					correct_count += 1
		
		# get attempted percent, correct percent and average time
		var attempt_percent: float
		var correct_percent: float
		var avg_time: float
		if attempted_count != 0:
			attempt_percent = float(attempted_count) / student_ids.size()
			correct_percent = float(correct_count) / attempted_count
			avg_time = float(total_time) / attempted_count
		else:
			attempt_percent = 0
			correct_percent = 0
			avg_time = 0
			
		var qn_stats = {
			"qn_content": qn_content,
			"attempt_percent": attempt_percent,
			"correct_percent": correct_percent,
			"avg_time": avg_time
		}
		stats.append(qn_stats)

	return stats

	
static func get_level_stats_by_student(level_id: String, student_id: String) -> Array:
	""" Get statistics for a level for a students.
	
	This function can only be used for both game boss levels and quiz levels.
	
	Args:
		level_id (String): Level ID.
		student_id (String): User ID of student.
		
	Returns:
		Array[Dictionary]: Returns an Array of statistics for each question in the level as Dictionaries. Each Dictionary contains:
			"qn_content" (String): Question content.
			"attempted" (String): "Yes" if student has attempted the question, "No" otherwise.
			"result" (String): "Correct" if the student got the question correct, 
				"Wrong" if the student got it wrong, 
				"-" if the student did not attempt the question.
			"time" (int/String): If the student attempted the question, this value is the time the student took as total seconds.
				Otherwise, the value is "-".
	
	"""
	# Get question docs
	var qn_docs: Array = yield(_query_questions_by_level(level_id), "completed")
	
	# get attempts
	var level_attempts: Array = yield(TowerBackend.get_level_attempt(student_id, level_id, "first"), "completed")
	
	# format stats
	var stats: Array = []
	var no_of_attempts: int = level_attempts.size()
	for i in range(qn_docs.size()):
		var qn_doc: FirestoreDocument = qn_docs[i]
		
		var qn_content: String = qn_doc.doc_fields["questionBody"]
		
		# check if question is attempted
		var attempted: String
		var result: String
		var time
		if i < no_of_attempts:
			var attempt: Dictionary = level_attempts[i]
			attempted = "Yes"
			result = "Correct" if attempt["correct"] else "Wrong"
			time = attempt["duration"]
		else:
			attempted = "No"
			result = "-"
			time = "-"
		
		var qn_stats: Dictionary = {
			"qn_content": qn_content,
			"attempted": attempted,
			"result": result,
			"time": time
		}
		stats.append(qn_stats)
	
	return stats
	

func _on_test_button_up():
	"""
	var query = FirestoreQuery.new().from("Question_Attempt").where("studentID", FirestoreQuery.OPERATOR.EQUAL, "student1", FirestoreQuery.OPERATOR.AND).where("questionID", FirestoreQuery.OPERATOR.EQUAL, "question1")
	var task = Firebase.Firestore.query(query)
	var output = yield(task, "task_finished")
	"""
	#var output = yield(_query_questions_by_level("numbers-10"), "completed")
	var output = yield(get_level_stats_by_student("iZKcmDRrSdc0zn8vU6ZnxaEpPGH2", "numbers-10"), "completed")
	print(output)


func _on_get_tower_stats_by_class_button_up():
	var output = yield(get_tower_stats_by_class("numbers-tower", ["dummyClass"]), "completed")
	print(output)


func _on_get_level_stats_by_class_button_up():
	var output = yield(get_level_stats_by_class("numbers-10", ["dummyClass"]), "completed")
	print(output)


func _on_get_level_stats_by_student_button_up():
	var output = yield(get_level_stats_by_student("numbers-10", "iZKcmDRrSdc0zn8vU6ZnxaEpPGH2"), "completed")
	print(output)


func _on_get_class_ids_and_names_button_up():
	var output = yield(get_class_ids_and_names("dummyteacher1"), "completed")
	print(output)


func _on_get_student_ids_and_names_button_up():
	var output = yield(get_student_ids_and_names(["dummyClass"]), "completed")
	print(output)


func _on_get_tower_ids_and_names_button_up():
	var output = yield(get_tower_ids_and_names(), "completed")
	print(output)


func _on_get_level_ids_and_names_button_up():
	var output = yield(get_level_ids_and_names("numbers-tower"), "completed")
	print(output)
