extends "res://addons/gut/test.gd"

var quiz_id1 = "quiz-test-quiz-1"
var quiz_id2 = "quiz-test-quiz-2"
var tower_id = "quiz-tower"
var teacher_id = "test-teacher"
var class_name1 = "test class 1"
var class_name2 = "test class 2"
var class_id1 = "test-class-1"
var class_id2 = "test-class-2"
var quiz_name1 = "test quiz 1"
var quiz_name2 = "test quiz 2"
var max_time = 100
var no_of_tries = 3
var publishing_date = Datetime.get_datetime_dict(2021, 10, 13, 10, 30, 00)
var qns = [{'qnContent': "test qn 1", 'wrongOption1': 1, 'wrongOption2': 2, 'wrongOption3': 3, 'correctOption': 4}]


func before_all():
	Firebase.Auth.login_with_email_and_password("admin@gmail.com", "cz3003ssad");
	yield(ClassBackend.create_class(teacher_id, class_name1), "completed")
	yield(ClassBackend.create_class(teacher_id, class_name2), "completed")
	yield(QuizBackend.create_quiz(tower_id, [class_id1], quiz_name1, max_time, no_of_tries, publishing_date, qns), "completed")


func after_all():
	yield(ClassBackend.delete_class(class_id1), "completed")
	yield(ClassBackend.delete_class(class_id2), "completed")
	yield(QuizBackend.delete_quiz(quiz_id1, []), "completed")
	yield(QuizBackend.delete_quiz(quiz_id2, []), "completed")
	

func test_create_quiz():
	# Create quiz
	yield(QuizBackend.create_quiz(tower_id, [class_id2], quiz_name2, max_time, no_of_tries, publishing_date, qns), "completed")
	
	# Verifiy that quiz level data is correct
	var coll = Firebase.Firestore.collection("Level")
	var task = coll.get(quiz_id2)
	var doc = yield(task, "task_finished")
	if not doc is FirestoreDocument:
		fail_test("Quiz level cannot be found")
	else:
		var data = doc.doc_fields
		assert_eq(data["attemptNo"], no_of_tries)
		assert_eq(data["levelDuration"], max_time)
		assert_eq(data["levelType"], "quiz")
		for key in publishing_date.keys():
			assert_eq(data["publishingDate"][key], publishing_date[key])
		assert_eq(data["quizName"], quiz_name2)
		assert_eq(data["towerID"], tower_id)
	
	# Verify question data is correct
	var query = FirestoreQuery.new()
	query.from("Question")
	query.where("levelID", FirestoreQuery.OPERATOR.EQUAL, quiz_id2)
	query.order_by("questionBody")
	task = Firebase.Firestore.query(query)
	var output = yield(task, "task_finished")
	if not output is Array:
		fail_test("Quiz questions cannot be found")
	elif output.size() != qns.size():
		fail_test("incorrect number of questions")
	else:
		var data = output[0].doc_fields
		assert_eq(data.get("levelID"), quiz_id2)
		assert_eq(data.get("questionBody"), qns[0]["qnContent"])
		var options = data.get("questionOptions")
		if not options is Array:
			fail_test("question options is in incorrect format")
		else:
			assert_has(options, qns[0]["wrongOption1"])
			assert_has(options, qns[0]["wrongOption2"])
			assert_has(options, qns[0]["wrongOption3"])
			assert_has(options, qns[0]["correctOption"])
		assert_eq(data.get("questionSoln"), qns[0]["correctOption"])
			
	# Check class data
	coll = Firebase.Firestore.collection("Class")
	task = coll.get(class_id2)
	doc = yield(task, "task_finished")
	var quiz_list = doc.doc_fields.get("quizList")
	assert_eq(quiz_list.size(), 1)
	assert_has(quiz_list, quiz_id2)


func test_get_quiz():
	var quiz = yield(QuizBackend.get_quiz(quiz_id1), "completed")
	if not quiz is Dictionary:
		fail_test("quiz is not a dictionary")
	else:
		assert_eq(quiz.get("towerID"), tower_id)
		assert_eq(quiz.get("attemptNo"), no_of_tries)
		assert_eq(quiz.get("levelDuration"), max_time)
		assert_eq(quiz.get("levelType"), "quiz")
		for key in publishing_date.keys():
			assert_eq(quiz.get("publishingDate").get(key), publishing_date[key])
		assert_eq(quiz.get("quizName"), quiz_name1)
		
		# Test qn data
		var qn_data = quiz.get("questions")
		if qn_data.size() != 1:
			fail_test("quiz should only have 1 question, instead got %d" % qn_data.size())
		assert_eq(qn_data[0].get("levelID"), quiz_id1)
		assert_eq(qn_data[0].get("questionBody"), qns[0]["qnContent"])
		var options = qn_data[0].get("questionOptions")
		assert_has(options, qns[0]["wrongOption1"])
		assert_has(options, qns[0]["wrongOption2"])
		assert_has(options, qns[0]["wrongOption3"])
		assert_has(options, qns[0]["correctOption"])
		assert_eq(qn_data[0].get("questionSoln"), qns[0]["correctOption"])
		

func test_get_quiz_ids_by_class():
	var quiz_ids = yield(QuizBackend.get_quiz_ids_by_class(class_id1), "completed")
	assert_eq(quiz_ids.size(), 1, "num")
	assert_has(quiz_ids, quiz_id1)


func test_get_quizzes_by_class():
	var quizzes = yield(QuizBackend.get_quizzes_by_class(class_id1), "completed")
	if quizzes.size() != 1:
		fail_test("should have gotten back 1 quiz, instead got back %d" % quizzes.size())
	else:
		var quiz = quizzes[0]
		
		# Test quiz settings data
		assert_eq(quiz.get("towerID"), tower_id)
		assert_eq(quiz.get("attemptNo"), no_of_tries)
		assert_eq(quiz.get("levelDuration"), max_time)
		assert_eq(quiz.get("levelType"), "quiz")
		for key in publishing_date.keys():
			assert_eq(quiz.get("publishingDate").get(key), publishing_date[key])
		assert_eq(quiz.get("quizName"), quiz_name1)
		
		# Test qn data
		var qn_data = quiz.get("questions")
		if qn_data.size() != 1:
			fail_test("quiz should only have 1 question, instead got %d" % qn_data.size())
		assert_eq(qn_data[0].get("levelID"), quiz_id1)
		assert_eq(qn_data[0].get("questionBody"), qns[0]["qnContent"])
		var options = qn_data[0].get("questionOptions")
		assert_has(options, qns[0]["wrongOption1"])
		assert_has(options, qns[0]["wrongOption2"])
		assert_has(options, qns[0]["wrongOption3"])
		assert_has(options, qns[0]["correctOption"])
		assert_eq(qn_data[0].get("questionSoln"), qns[0]["correctOption"])
	
