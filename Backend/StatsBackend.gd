extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Firebase.Auth.login_with_email_and_password("admin@gmail.com", "cz3003ssad")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _get_student_docs_by_class(class_id: String) -> Array:
	""" Gets the firestore documents of all students in a specific class.
	
	Args:
		class_id (String): Class ID.
		
	Returns:
		Array[FirestoreDocument]: Documents of the students in the class.
	
	"""
	var query: FirestoreQuery = FirestoreQuery.new()
	query.from("User", false)
	query.where("classId", FirestoreQuery.OPERATOR.EQUAL, class_id)
	var task: FirestoreTask = Firebase.Firestore.query(query)
	var docs: Array = yield(task, "task_finished")
	return docs


func get_tower_boss_level_ids(tower_id: String) -> Array:
	""" Gets the level IDs for boss levels in a specific tower.
	
	Args:
		tower_id (String): Tower ID.
	
	Returns:
		Array[String]: Level IDs of the boss levels in the tower.
	
	"""
	# Get all level ids
	var query: FirestoreQuery = FirestoreQuery.new()
	query.from("Level")
	query.where("towerID", FirestoreQuery.OPERATOR.EQUAL, tower_id)
	var task: FirestoreTask = Firebase.Firestore.query(query)
	var docs: Array = yield(task, "task_finished")

	# Get boss level ids
	var boss_level_ids = []
	for doc in docs:
		var level_no: int = doc.doc_fields["level"]
		if level_no % 5 == 0:
			boss_level_ids.append(doc.doc_name)
	
	return boss_level_ids


func get_tower_stats_by_class(class_ids: Array, tower_id: String) -> Array:
	""" Get the tower statistics informatino for a number of classes.
	
	Args:
		class_id (Array[String]): An Array of class IDs.
		tower_id (String): Tower ID.
		
	Returns:
		Array[Dictionary]: An Array of student statistics information as Dictionaries.
			Each Dictionary contains:
				"student_name" (String): Student's name
				"max_level" (int): Last level attempted by the student for the tower. 
				"avg_score" (float): Student's average score for attempted boss levels in the tower
				"avg_time" (float): Average time student took to complete each attempted boss level in the tower. 
					Timing is expressed as total number of seconds.
	
	"""
	var student_docs: Array = []
	for class_id in class_ids:
		var class_student_docs = yield(_get_student_docs_by_class(class_id), "completed")
		student_docs.append_array(class_student_docs)
	
	var boss_level_ids: Array = yield(get_tower_boss_level_ids(tower_id), "completed")
	
	var stats: Array = []
	for student_doc in student_docs:
		var student_id: String = student_doc.doc_name
		var max_level: int = yield(TowerBackend.get_last_level_attempted(student_id, tower_id), "completed")
		
		var avg_score: float = 0.0
		var avg_timing: float = 0.0
		var no_of_levels: int = max_level / 5 # number of attempted boss levels
		for i in range(no_of_levels):
			var level_id = boss_level_ids[i]
			
			# For each level, get level score and timing
			var level_attempts = yield(TowerBackend.get_level_attempt(student_id, level_id, "first"), "completed")
			var level_score: float = 0.0
			var level_timing: float = 0.0
			for attempt in level_attempts:
				if attempt["correct"]:
					level_score += 1.0
				level_timing += attempt["duration"]
			
			# sum up scores and timings for each level
			avg_score += level_score
			avg_timing += level_timing
		
		# calculate average score and timing
		if no_of_levels != 0:
			avg_score /= no_of_levels
			avg_timing /= no_of_levels
		
		# format student's stats as a dict and add it to the list
		var student_stats = {
			"student_name" : student_doc.doc_fields["name"], 
			"max_level": max_level, 
			"avg_score": avg_score, 
			"avg_time": avg_timing
		}
		stats.append(student_stats)
		
	return stats		


func _on_test_button_up():
	#var output = yield(get_tower_boss_level_ids("numbers-tower"), "completed")
	var output = yield(get_tower_stats_by_class(["dummyClass"], "numbers-tower"), "completed")
	print(output)
