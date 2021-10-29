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
		query.where("classID", FirestoreQuery.OPERATOR.EQUAL, class_id)
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


static func get_tower_stats_by_class(tower_id: String, class_ids: Array) -> Array:
	""" Get statistics for the boss levels in a game tower, for students in specified classes.
	
	This function is for for game towers only.
	
	Args:
		tower_id (String): Game tower ID.
		class_ids(Array[String]): An Array of class IDs.
		
	Returns:
		Array[Dictionary]: Returns an Array of statistics for each student as Dictionaries. Each Dictionary contains:
			"student_name" (String): Student's name.
			"max_level" (int): Last level attempted by student for the tower.
			"avg_score" (float): Student's average score for attempted boss levels in the tower.
			"avg_time" (float): Student's average timing for attempted boss levels in the tower. Timing is expressed as total seconds.
	
	"""
	var student_info: Dictionary = yield(get_student_ids_and_names(class_ids), "completed")
	# create empty attempts info entries for each student
	var student_attempt_info = {}
	for student_name in student_info.keys():
		var attempt_info = {
			"student_name": student_name,
			"boss_attempts": {},
			"max_level": 0
		}
		student_attempt_info[student_info[student_name]] = attempt_info
	
	# get attempts
	var docs: Array = []
	var student_ids: Array = student_info.values()
	# IN can only handle arrays with 10 elements or less, so split the ids into groups of 10
	var student_no: int = student_ids.size()
	var student_id_groups: Array = []
	for start in range(0, student_no, 10):
		var end = int(min(student_no, start+9))
		student_id_groups.append(student_ids.slice(start, end))
	for group in student_id_groups:
		var query: FirestoreQuery = FirestoreQuery.new()
		query.from("Question_Attempt", false)
		query.where("studentID", FirestoreQuery.OPERATOR.IN, group, FirestoreQuery.OPERATOR.AND)
		query.where("towerID", FirestoreQuery.OPERATOR.EQUAL, tower_id, FirestoreQuery.OPERATOR.AND)
		query.where("type", FirestoreQuery.OPERATOR.EQUAL, "first")
		var task = Firebase.Firestore.query(query)
		docs.append_array(yield(task, "task_finished"))

	# sort attempts by student
	for doc in docs:
		# get student id
		var student_id: String = doc.doc_fields["studentID"]
		# get level no
		var qn_id: String = doc.doc_fields["questionID"]
		var level_no: int = int(qn_id.substr(qn_id.length()-4, 2))
		# set max level
		student_attempt_info[student_id]["max_level"] = level_no
		# add attempt if the attempt is boss attempt
		if level_no % 5 == 0:
			if student_attempt_info[student_id]["boss_attempts"].has(level_no):
				student_attempt_info[student_id]["boss_attempts"][level_no].append(doc)
			else:
				student_attempt_info[student_id]["boss_attempts"][level_no] = [doc]
		
	# get stats for each student;
	var stats: Array = []
	for student_id in student_attempt_info.keys():
		var avg_score: float = 0
		var avg_time: float = 0
		var boss_attempts: Dictionary = student_attempt_info[student_id]["boss_attempts"]
		for boss_level_no in boss_attempts.keys():
			# get level score and time
			var level_score: int = 0
			var level_time: int = 0
			var level_attempts: Array = boss_attempts[boss_level_no]
			for attempt in level_attempts:
				level_score += int(attempt.doc_fields["correct"])
				level_time += attempt.doc_fields["duration"]
			# add level score and time to average score and time
			avg_score += level_score
			avg_time += level_time
		# calculate average score and time
		var attempted_levels: float = float(boss_attempts.size())
		if attempted_levels != 0:
			avg_score /= attempted_levels
			avg_time /= attempted_levels
		# append student stats
		var student_stats = {
			"student_name": student_attempt_info[student_id]["student_name"],
			"max_level": student_attempt_info[student_id]["max_level"],
			"avg_score": avg_score,
			"avg_time": avg_time
		}
		stats.append(student_stats)
		
	return stats


static func get_level_stats_by_class(level_id: String, class_ids: Array) -> Array:
	""" Get statistics for a level for students in specified classes.
	
	This function can only be used for boss levels in game towers.
	
	Args:
		level_id (String): Level ID.
		class_ids(Array[String]): An Array of class IDs.
		
	Returns:
		Array[Dictionary]: Returns an Array of statistics for each question in the level as Dictionaries. Each Dictionary contains:
			"qn_no" (int): Question number.
			"attempt_percent" (float): Percentage of students who attempted the question.
			"correct_percent" (float): Out of the students who attempted the question, the percentage of them that got the question correct.
			"avg_time" (float): Average timing of students who attempted the question. Timing is expressed as total seconds.
	
	"""
	var student_info: Dictionary = yield(get_student_ids_and_names(class_ids), "completed")
	var student_no: int = student_info.size()
	
	# initialize question_stats
	var stats: Dictionary = {}
	for qn_no in range(1, 6):
		var qn_id: String = "%s-%d" % [level_id, qn_no]
		var qn_stats: Dictionary = {
			"qn_no": qn_no,
			"attempt_percent": 0,
			"correct_percent": 0,
			"avg_time": 0
		}
		stats[qn_id] = qn_stats
	# if no students in the classes, return empty stats
	if student_no == 0:
		return stats.values()
	
	# get attempts
	# only 1 IN filter can be used per query, so query all attempts in the tower and filter the data
	var docs: Array = []
	var student_ids: Array = student_info.values()
	# IN can only handle arrays with 10 elements or less, so split the ids into groups of 10
	var student_id_groups: Array = []
	for start in range(0, student_no, 10):
		var end = int(min(student_no, start+9))
		student_id_groups.append(student_ids.slice(start, end))
	for group in student_id_groups:
		var tower_id: String = "%s-tower" % level_id.substr(0, level_id.length()-3)
		var query: FirestoreQuery = FirestoreQuery.new()
		query.from("Question_Attempt", false)
		query.where("studentID", FirestoreQuery.OPERATOR.IN, group, FirestoreQuery.OPERATOR.AND)
		query.where("towerID", FirestoreQuery.OPERATOR.EQUAL, tower_id, FirestoreQuery.OPERATOR.AND)
		query.where("type", FirestoreQuery.OPERATOR.EQUAL, "first")
		query.order_by("questionID")
		var task = Firebase.Firestore.query(query)
		docs.append_array(yield(task, "task_finished"))
	
	var qn_ids: Array = stats.keys()
	for doc in docs:
		var qn_id: String = doc.doc_fields["questionID"]
		# if not from the correct level, skip
		if not qn_id in qn_ids:
			continue
		# add to stats
		stats[qn_id]["attempt_percent"] += 1
		stats[qn_id]["correct_percent"] += int(doc.doc_fields["correct"])
		stats[qn_id]["avg_time"] += doc.doc_fields["duration"]
	
	# calculate stats
	for qn_stats in stats.values():
		var attempt_no: int = qn_stats["attempt_percent"]
		if attempt_no != 0:
			qn_stats["attempt_percent"] /= float(student_no)
			qn_stats["correct_percent"] /= float(attempt_no)
			qn_stats["avg_time"] /= float(attempt_no)
	
	return stats.values()


static func get_level_stats_by_student(level_id: String, student_id: String) -> Array:
	""" Get statistics for a level for a students.
	
	This function can only be used for boss levels in game towers.
	
	Args:
		level_id (String): Level ID.
		student_id (String): User ID of student.
		
	Returns:
		Array[Dictionary]: Returns an Array of statistics for each question in the level as Dictionaries. Each Dictionary contains:
			"qn_no" (int): Question number.
			"attempted" (String): "Yes" if student has attempted the question, "No" otherwise.
			"result" (String): "Correct" if the student got the question correct, 
				"Wrong" if the student got it wrong, 
				"-" if the student did not attempt the question.
			"time" (int/String): If the student attempted the question, this value is the time the student took as total seconds.
				Otherwise, the value is "-".
	
	"""
	# get attempts
	var level_attempts: Array = yield(TowerBackend.get_level_attempt(student_id, level_id, "first"), "completed")
	
	# initialize question stats
	var stats: Dictionary = {}
	for qn_no in range(1, 6):
		var qn_id = "%s-%d" % [level_id, qn_no]
		var qn_stats = {
			"qn_no": qn_no,
			"attempted": "No",
			"result": "-",
			"time": "-"
		}
		stats[qn_id] = qn_stats
	
	# get stats from attempts
	for attempt in level_attempts:
		var qn_id = attempt["questionID"]
		stats[qn_id]["attempted"] = "Yes"
		stats[qn_id]["result"] = "Correct" if attempt["correct"] else "Wrong"
		stats[qn_id]["time"] = attempt["duration"]
	
	return stats.values()
	

static func get_quiz_stats_by_class(quiz_level_id: String, class_ids: Array) -> Array:
	""" Get quiz stats for each student in a few classes.
	
	Args:
		quiz_level_id (String): Quiz's level ID.
		class_id (Array[String]): Class IDs.
		
	Returns:
		Array[Dictionary]: An Array of student stats as Dictionaries. The Dictionary has the following keys:
			"student_name" (String): Student's name.
			"time" (int/String): Total time student took to complete the quiz.
				If the student has attempted the quiz, this value is an int representing the time as total seconds.
				If the student has not attempted the quiz, this value is "-".
			"qn_attempts" (Array[Dictionary]): An Array of question attempts as Dictionaries. Each Dictionary has the following keys:
				"qn_content" (String): The quiz question content.
				"correct" (String): Whether the student got the question correct.
					If the student got the question correct, this value is "Correct".
					If the student got the question wrong, this value is "Wrong".
					If the student did not attempt the question, this value is "-".
	
	"""
	# get sutdent info
	var student_info: Dictionary = yield(get_student_ids_and_names(class_ids), "completed")
	
	# get quiz question docs
	var qn_docs: Array = yield(QuizBackend._query_quiz_questions(quiz_level_id), "completed")
	
	# get quiz attempt docs
	# get attempts
	var attempt_docs: Array = []
	var student_ids: Array = student_info.values()
	# IN can only handle arrays with 10 elements or less, so split the ids into groups of 10
	var student_no: int = student_ids.size()
	var student_id_groups: Array = []
	for start in range(0, student_no, 10):
		var end = int(min(student_no, start+9))
		student_id_groups.append(student_ids.slice(start, end))
	for group in student_id_groups:
		var query: FirestoreQuery = FirestoreQuery.new()
		query.from("Quiz_Attempt", false)
		query.where("studentID", FirestoreQuery.OPERATOR.IN, group, FirestoreQuery.OPERATOR.AND)
		query.where("quizID", FirestoreQuery.OPERATOR.EQUAL, quiz_level_id)
		var task: FirestoreTask = Firebase.Firestore.query(query)
		attempt_docs.append_array(yield(task, "task_finished"))
	
	# initialize stats
	var qn_attempts: Dictionary = {}
	for qn_doc in qn_docs:
		qn_attempts[qn_doc.doc_name] = {
			"qn_content": qn_doc.doc_fields["questionBody"],
			"result": "-"
		}
	var stats: Dictionary= {}
	for student_name in student_info.keys():
		var student_stats: Dictionary = {
			"student_name": student_name,
			"time": "-",
			"qn_attempts": qn_attempts.duplicate(true)
		}
		stats[student_info[student_name]] = student_stats
	
	# get stats from attempts
	for attempt_doc in attempt_docs:
		var student_id: String = attempt_doc.doc_fields["studentID"]
		stats[student_id]["time"] = attempt_doc.doc_fields["duration"]
		var attempts: Dictionary = attempt_doc.doc_fields["questionAttempts"]
		for qn_id in attempts:
			stats[student_id]["qn_attempts"][qn_id]["result"] = "Correct" if attempts[qn_id] else "Wrong"
	
	# convert question attempts in stats from dict of dicts to array of dicts
	for student_stats in stats.values():
		student_stats["qn_attempts"] = student_stats["qn_attempts"].values()
	
	return stats.values()


static func get_quiz_stats_by_student(quiz_level_id: String, student_id: String) -> Dictionary:
	""" Get quiz stats for a student.
	
	Args:
		quiz_level_id (String): Quiz's level ID.
		student_id (String): Student's user ID.
		
	Returns:
		Dictionary: The fomatted student stats. The Dictionary has the following keys:
			"time" (int/String): Total time student took to complete the quiz.
				If the student has attempted the quiz, this value is an int representing the time as total seconds.
				If the student has not attempted the quiz, this value is "-".
			"qn_attempts" (Array[Dictionary]): An Array of question attempts as Dictionaries. Each Dictionary has the following keys:
				"qn_content" (String): The quiz question content.
				"correct" (String): Whether the student got the question correct.
					If the student got the question correct, this value is "Correct".
					If the student got the question wrong, this value is "Wrong".
					If the student did not attempt the question, this value is "-".
	
	"""
	# get quiz questions
	var qn_docs: Array = yield(QuizBackend._query_quiz_questions(quiz_level_id), "completed")
	
	# query quiz document
	var attempt_doc = yield(QuizBackend._get_quiz_attempt_doc(student_id, quiz_level_id), "completed")
	
	# initialize stats
	var stats: Dictionary= {
		"time": "-",
		"qn_attempts": {}
	}
	for qn_doc in qn_docs:
		stats["qn_attempts"][qn_doc.doc_name] = {
			"qn_content": qn_doc.doc_fields["questionBody"],
			"result": "-"
		}
	
	# quiz was not attempted
	if not attempt_doc is FirestoreDocument:
		return stats
	
	# quiz was attempted, get stats from attempts
	stats["time"] = attempt_doc.doc_fields["duration"]
	var qn_attempts: Dictionary = attempt_doc.doc_fields["questionAttempts"]
	for qn_id in qn_attempts.keys():
		stats["qn_attempts"][qn_id]["result"] = "Correct" if qn_attempts[qn_id] else "Wrong"
	# convert qn_attempts from dict of dicts to array of dicts
	stats["qn_attempts"] = stats["qn_attempts"].values()
	
	return stats


func _on_test_button_up():
	var temp
	var output
	var id = "numbers-10"
	temp = OS.get_unix_time()
	output = yield(get_level_stats_by_class(id, ["dummyClass"]), "completed")
	print(output)
	print(OS.get_unix_time()-temp)
	print()
	temp = OS.get_unix_time()
	#output = yield(test(id, ["dummyClass"]), "completed")
	print(output)
	print(OS.get_unix_time()-temp)
	print()


func _on_get_tower_stats_by_class_button_up():
	var temp = OS.get_unix_time()
	var output = yield(get_tower_stats_by_class("numbers-tower", ["Class-A"]), "completed")
	print("time taken: %ds" % (OS.get_unix_time()-temp))
	print(output)


func _on_get_level_stats_by_class_button_up():
	var temp = OS.get_unix_time()
	var output = yield(get_level_stats_by_class("numbers-05", ["Class-A"]), "completed")
	print("time taken: %ds" % (OS.get_unix_time()-temp))
	print(output)


func _on_get_level_stats_by_student_button_up():
	var temp = OS.get_unix_time()
	var output = yield(get_level_stats_by_student("numbers-10", "iZKcmDRrSdc0zn8vU6ZnxaEpPGH2"), "completed")
	print("time taken: %ds" % (OS.get_unix_time()-temp))
	print(output)


func _on_get_quiz_stats_by_class_button_up():
	var temp = OS.get_unix_time()
	var output = yield(get_quiz_stats_by_class("quiz-hard-test-:(", ["Class-A"]), "completed")
	print("time taken: %ds" % (OS.get_unix_time()-temp))
	for e in output:
		print(e)


func _on_get_quiz_stats_by_student_button_up():
	var temp = OS.get_unix_time()
	var output = yield(get_quiz_stats_by_student("quiz-hard-test-:(", "student1"), "completed")
	print("time taken: %ds" % (OS.get_unix_time()-temp))
	print(output)


func _on_get_class_ids_and_names_button_up():
	var output = yield(get_class_ids_and_names("dummyteacher1"), "completed")
	print(output)


func _on_get_student_ids_and_names_button_up():
	var output = yield(get_student_ids_and_names(["Class-A"]), "completed")
	print(output)


func _on_get_tower_ids_and_names_button_up():
	var output = yield(get_tower_ids_and_names(), "completed")
	print(output)


func _on_get_level_ids_and_names_button_up():
	var output = yield(get_level_ids_and_names("numbers-tower"), "completed")
	print(output)
