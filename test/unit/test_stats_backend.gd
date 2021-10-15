extends "res://addons/gut/test.gd"

var teacher_id = "test-teacher"

var class_name_ = "Test Class"
var class_id = "Test-Class"

var student_id = "test-student"
var student_name = "Test Student"

var tower_ids = ["fraction-tower", "numbers-tower", "ratio-tower", "quiz-tower"]
var tower_names = ["Fraction Tower", "Numbers Tower", "Ratio Tower", "Quiz Tower"]

var tower_topic = "numbers"
var tower_id = "%s-tower" % tower_topic
var max_level = 5
var level_id = "%s-%02d" % [tower_topic, max_level]


func before_all():
	# Create test class
	ClassBackend.create_class(teacher_id, class_name_)
	
	# Create test student
	var coll = Firebase.Firestore.collection("User")
	var task = coll.add(student_id, {"name": student_name, "classId": class_id})
	yield(task, "task_finished")
	
	# Create first attempts for test student 
	for level_no in range(1, max_level+1):
		var max_qns
		if level_no % 5 == 0:
			max_qns = 4 #skip last question for boss levels
		else:
			max_qns = 3
		var attempts = []
		for qn_no in range(1, max_qns+1):
			var id = "%s-%02d-%d" % [tower_topic, level_no, qn_no]
			var attempt = {
				"correct": true, # set correct for all attempts
				"duration": 100, 
				"questionID": id,
				"studentID": student_id,
				"type": "first"
			}
			yield(TowerBackend._add_question_attempt(attempt), "completed")
		


func after_all():
	# Delete test class
	ClassBackend.delete_class(class_id)
	
	# Delete test student
	var coll = Firebase.Firestore.collection("User")
	var task = coll.delete(student_id)
	yield(task, "task_finished")
	
	# Delete attempts
	var query = FirestoreQuery.new()
	query.from("Question_Attempt")
	query.where("studentID", FirestoreQuery.OPERATOR.EQUAL, student_id)
	task = Firebase.Firestore.query(query)
	var docs = yield(task, "task_finished")
	coll = Firebase.Firestore.collection("Question_Attempt")
	for doc in docs:
		task = coll.delete(doc.doc_name)
		yield(task, "task_finished")


func test_get_class_ids_and_names():
	var class_info = yield(StatsBackend.get_class_ids_and_names(teacher_id), "completed")
	assert_has(class_info, class_name_)
	assert_eq(class_info.get(class_name_), class_id)


func test_get_student_ids_and_names():
	var student_info = yield(StatsBackend.get_student_ids_and_names([class_id]), "completed")
	assert_has(student_info, student_name)
	assert_eq(student_info.get(student_name), student_id)


func test_get_tower_ids_and_names():
	var tower_info = yield(StatsBackend.get_tower_ids_and_names(), "completed")
	assert_eq(tower_info.size(), 4)
	for i in range(tower_ids.size()):
		assert_has(tower_info, tower_names[i])
		assert_eq(tower_info.get(tower_names[i]), tower_ids[i])


func test_get_level_ids_and_names():
	var level_info = yield(StatsBackend.get_level_ids_and_names(tower_id), "completed")
	for no in range(5, max_level+1, 5):
		var name_ = "Level %d" % no
		var id = "%s-%02d" % [tower_topic, no]
		assert_has(level_info, name_)
		assert_eq(level_info.get(name_), id)


func test_get_tower_stats_by_class():
	var stats = yield(StatsBackend.get_tower_stats_by_class(tower_id, [class_id]), "completed")
	if stats.size() != 1:
		fail_test("should have gotten 1 stats entry, instead got %d" % stats.size())
	else:
		# check that stats info is correct
		stats = stats[0]
		assert_has(stats, "student_name")
		assert_eq(stats.get("student_name"), student_name)
		assert_has(stats, "max_level")
		assert_eq(stats.get("max_level"), max_level)
		assert_has(stats, "avg_score")
		assert_eq(stats.get("avg_score"), 4.0)
		assert_has(stats, "avg_time")
		assert_eq(stats.get("avg_time"), 600.0)


func test_get_level_stats_by_class():
	var stats = yield(StatsBackend.get_level_stats_by_class(level_id, [class_id]), "completed")
	if stats.size() != 5:
		fail_test("should have gotten 5 stats entry, instead got %d" % stats.size())
	else:
		# check that stats info is correct
		for i in range(5):
			var entry = stats[i]
			assert_has(entry, "qn_content")
			
			var percent = 0.0 if (i == 4) else 1.0
			
			assert_has(entry, "attempt_percent")
			assert_eq(entry.get("attempt_percent"), percent)
			
			assert_has(entry, "correct_percent")
			assert_eq(entry.get("correct_percent"), percent)
			
			assert_has(entry, "avg_time")
			var time = 0.0 if (i == 4) else 100.0
			assert_eq(entry.get("avg_time"), time)


func test_get_level_stats_by_student():
	var stats = yield(StatsBackend.get_level_stats_by_student(level_id, student_id), "completed")
	if stats.size() != 5:
		fail_test("should have gotten 5 stats entry, instead got %d" % stats.size())
	else:
		# check that stats info is correct
		for i in range(5):
			var entry = stats[i]
			assert_has(entry, "qn_content")
			
			assert_has(entry, "attempted")
			var attempted = "No" if (i == 4) else "Yes"
			assert_eq(entry.get("attempted"), attempted)
			
			assert_has(entry, "result")
			var result = "-" if (i == 4) else "Correct"
			assert_eq(entry.get("result"), result)
			
			assert_has(entry, "time")
			var time = "-" if (i == 4) else 100
			assert_eq(entry.get("time"), time)
