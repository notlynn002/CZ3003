extends "res://addons/gut/test.gd"

var all_tower_ids = ["fraction-tower", "numbers-tower", "quiz-tower", "ratio-tower"]
var tower_id = "numbers-tower"
var no_of_levels = 10
var level_id = "numbers-01"
var student_id1 = "test-student1"
var student_id2 = "test-student2"
var student_id3 = "test-student3"
var student_id4 = "test-student4"
var qn_attempt1 = {"questionID": "numbers-01-1", "correct" : false, "duration": 100}
var qn_attempt2 = {"questionID": "numbers-01-2", "correct" : true, "duration": 100}
var qn_attempt3 = {"questionID": "numbers-01-3", "correct" : true, "duration": 100}
var attempts = [qn_attempt1, qn_attempt2, qn_attempt3]

func before_all():
	# Create question attempt to test get function
	yield(TowerBackend._add_first_attempts(student_id1, attempts), "completed")
	yield(TowerBackend.submit_attempt(student_id3, attempts), "completed")
	yield(TowerBackend.submit_attempt(student_id4, attempts), "completed")


func after_all():
	# Delete all question attempts created for tests
	var docs = []
	for student_id in [student_id1, student_id2, student_id3, student_id4]:
		var query = FirestoreQuery.new()
		query.from("Question_Attempt", false)
		query.where("studentID", FirestoreQuery.OPERATOR.EQUAL, student_id)
		var task = Firebase.Firestore.query(query)
		docs.append_array(yield(task, "task_finished"))
	
	var coll = Firebase.Firestore.collection("Question_Attempt")
	for doc in docs:
		var task = coll.delete(doc.doc_name)
		yield(task, "task_finished")


func test_get_all_towers():
	var tower_ids = yield(TowerBackend.get_all_towers(), "completed")
	assert_eq(tower_ids.size(), all_tower_ids.size())
	for id in all_tower_ids:
		assert_true(tower_ids.has(id))


func test_get_level_for_tower():
	var level_ids = yield(TowerBackend.get_level_for_tower(tower_id), "completed")
	assert_eq(level_ids.size(), no_of_levels)
	for no in range(1, no_of_levels+1):
		var id = "numbers-%02d" % no
		assert_true(level_ids.has(id))


func test_get_questions_by_level():
	var qns = yield(TowerBackend.get_questions_by_level(level_id), "completed")
	assert_eq(qns.size(), 3)
	for qn in qns:
		assert_eq(qn.get("levelID"), level_id)
		assert_has(qn, "questionBody")
		assert_has(qn, "questionExplanation")
		var options = qn.get("questionOptions")
		if not options is Array:
			fail_test("question options is not an array")
		else:
			assert_eq(options.size(), 4)
			assert_has(options, qn.get("questionSoln"))


func test_get_last_level_attempted():
	var level = yield(TowerBackend.get_last_level_attempted(student_id1, tower_id), "completed")
	assert_eq(level, 1)


func test_get_level_attempt():
	var level_attempt = yield(TowerBackend.get_level_attempt(student_id1, level_id, "first"), "completed")
	if not level_attempt is Array:
		fail_test("should have gotten an array of question attempts, did not") 
	elif level_attempt.size() != attempts.size():
		fail_test("should have gotten %d question attempt, instead got %d" % [attempts.size(), level_attempt.size()])
	else:
		# Check if attempt contents are correct
		for i in range(level_attempt.size()):
			for key in attempts[i].keys():
				assert_eq(level_attempt[i].get(key), attempts[i][key])


func test_submit_first_attempt():
	yield(TowerBackend.submit_attempt(student_id2, attempts), "completed")
	
	# check if first and best attempts were written
	for type in ["first", "best"]:
		var level_attempt = yield(TowerBackend.get_level_attempt(student_id2, level_id, type), "completed")
		if not level_attempt is Array:
			fail_test("attempts were not submitted correctly") 
		elif level_attempt.size() != attempts.size():
			fail_test("should have written %d attempts, instead wrote %d" % [attempts.size(), level_attempt.size()])
		else:
			# Check if attempt contents are correct
			for i in range(level_attempt.size()):
				for key in attempts[i].keys():
					assert_eq(level_attempt[i].get(key), attempts[i][key])


func test_submit_best_attempt():
	# Edit attempt data to make best attempt
	# current attempt score is 2/3, best attempt score will be 3/3
	var best_attempt = attempts.duplicate(true)
	best_attempt[0]["correct"] = true
	
	# Submit best attempt
	yield(TowerBackend.submit_attempt(student_id3, best_attempt), "completed")
	
	# check that attempts have been updated to best attempts
	var level_attempt = yield(TowerBackend.get_level_attempt(student_id3, level_id, "best"), "completed")
	if not level_attempt is Array:
		fail_test("attempts were not submitted correctly") 
	elif level_attempt.size() != attempts.size():
		fail_test("should have been %d attempts, instead there's %d" % [attempts.size(), level_attempt.size()])
	else:
		# Check if attempts have been updated
		for attempt in level_attempt:
			assert_eq(attempt.get("correct"), true)
			

func test_submit_not_best_attempt():
	# Edit attempt data to make it worst than current best attempt
	# current attempt score is 2/3, this test attempt score will be 1/3
	var not_best_attempt = attempts.duplicate(true)
	not_best_attempt[1]["correct"] = false
	
	# Submit best attempt
	yield(TowerBackend.submit_attempt(student_id4, not_best_attempt), "completed")
	
	# check that best attempts have not been updated
	var level_attempt = yield(TowerBackend.get_level_attempt(student_id4, level_id, "best"), "completed")
	if not level_attempt is Array:
		fail_test("attempts were not submitted correctly") 
	elif level_attempt.size() != attempts.size():
		fail_test("should have been %d attempts, instead there's %d" % [attempts.size(), level_attempt.size()])
	else:
		assert_eq(level_attempt[0].get("correct"), false)
		assert_eq(level_attempt[1].get("correct"), true)
		assert_eq(level_attempt[2].get("correct"), true)
