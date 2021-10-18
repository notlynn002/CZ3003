extends CanvasLayer

# Declare member variables here. Examples:
var studentID
var id
var arenaType
var duration
var character
var questions

export (PackedScene) var King
export (PackedScene) var Archer
export (PackedScene) var Huntress
export (PackedScene) var Samurai
export (PackedScene) var Question
export (PackedScene) var Answer

func init(stuID, arenaID, type):
	id = arenaID
	studentID = stuID
	arenaType = type
	

# Called when the node enters the scene tree for the first time.
func _ready(): 
	$Popup.hide()
	
	# reset score & attempt
	Globals.score = 0
	Globals.attempt = []
	
	Firebase.Auth.login_with_email_and_password("admin@gmail.com", "cz3003ssad")
	# get student's selected character from db
	character = "king" # set as king for now
	if character == "king":
		var king = King.instance() # create an instance of king object
		# initialise starting position on map
		king.position.x = 344
		king.position.y = 856
		add_child(king) # add king to scene
	elif character == "archer":
		var archer = Archer.instance() # create an instance of archer object
		# initialise starting position on map
		archer.position.x = 344
		archer.position.y = 856
		add_child(archer) # add archer to scene
	elif character == "huntress":
		var huntress = Huntress.instance() # create an instance of huntress object
		# initialise starting position on map
		huntress.position.x = 344
		huntress.position.y = 856
		add_child(huntress) # add huntress to scene
	elif character == "samurai":
		var samurai = Samurai.instance() # create an instance of samurai object
		# initialise starting position on map
		samurai.position.x = 344
		samurai.position.y = 856
		add_child(samurai) # add samurai to scene
	
	if arenaType == 'challenge':
		var challenge = yield(getChallengeByID(id), "completed")
		questions = challenge['questionList']
		duration = 600
	elif arenaType == 'quiz':
		var quiz = yield(get_quiz(id), "completed")
		questions = quiz['questions']
		duration = quiz['levelDuration']
		var currAttempts = yield(check_max_attempt_reached(Globals.currUser.userId, id), "completed") # this fxn is not working
#		if currAttempts:
#			$Popup.show() 
			
	$Timer.set_wait_time(duration)
	$Timer.start()
	$TimerLabel.text = "Time left: " +  "%d:%02d" % [floor($Timer.time_left / 60), int($Timer.time_left) % 60]
	print(questions)
	for i in range(questions.size()):
#		var question = 	yield(getQuestion(questions[i]), 'completed')
		print(i)
		var qn = Question.instance()
		qn.init(str(i+1), questions[i]['questionBody'])
		
		var ans1 = Answer.instance()
		ans1.init(questions[i]['questionID'], questions[i]['questionOptions'][0], questions[i]['questionSoln'])
		ans1.position.x = 60
		ans1.position.y = 450
		
		var ans2 = Answer.instance()
		ans2.init(questions[i]['questionID'], questions[i]['questionOptions'][1], questions[i]['questionSoln'])
		ans2.position.x = 550
		ans2.position.y = 450
		
		var ans3 = Answer.instance()
		ans3.init(questions[i]['questionID'], questions[i]['questionOptions'][2], questions[i]['questionSoln'])
		ans3.position.x = 1030
		ans3.position.y = 450
		
		var ans4 = Answer.instance()
		ans4.init(questions[i]['questionID'], questions[i]['questionOptions'][3], questions[i]['questionSoln'])
		ans4.position.x = 1550
		ans4.position.y = 450
		
		add_child(qn)
		add_child(ans1)
		add_child(ans2)
		add_child(ans3)
		add_child(ans4)
		
		yield(Coroutines.await_any_signal([ans1, "answered", ans2, "answered", ans3, "answered", ans4, "answered"]), "completed")
		
	print("exited for loop")
	# when done with for loop
	# get remaining time
	var time_left = $Timer.time_left
	# check type & see if is quiz or challenge
	# save score and time to corresponsing db
	# navigate to home page
	if arenaType == 'quiz':
		var attempt_record = {}
		for i in range(Globals.attempt.size()):
			attempt_record[Globals.attempt[i][0]] = Globals.attempt[i][1]
			
		print(attempt_record)
			
		submit_quiz_attempt(Globals.currUser.userId, id, time_left, attempt_record)
	elif arenaType == 'challenge':
		updateChallengeResult(id, Globals.score, time_left, Globals.currUser.userId)
		
	# can display score before navigating back
	
	var homePage = load('res://Game Play/StudentHomePage.tscn').instance()
	get_tree().root.add_child(homePage)
	self.queue_free()
	
# warning-ignore:unused_argument
func _process(delta):
	$TimerLabel.text = "Time left: " +  "%d:%02d" % [floor($Timer.time_left / 60), int($Timer.time_left) % 60]
	
	# terminate game when time's up
	if $Timer.time_left <= 0:
		if arenaType == 'quiz':
			var attempt_record = {}
			for i in range(Globals.attempt.size()):
				attempt_record[Globals.attempt[i][0]] = Globals.attempt[i][1]
				
			submit_quiz_attempt(Globals.currUser.userId, id, 0, attempt_record)
		elif arenaType == 'challenge':
			updateChallengeResult(id, Globals.score, 0, Globals.currUser.userId)
			
func _on_CloseButton_pressed():
	var root = get_tree().root
	var homePage = load("res://Game Play/StudentHomePage.tscn").instance()
	root.add_child(homePage)
	self.queue_free()
	get_node('/root/ArenaPage').queue_free()


######## BACKEND FUNCTIONS ###########
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
	
	Raises:
		ERR_INVALID_PARAMETER: If quiz level ID is invalid.
		
	"""
	var quiz: Dictionary
	
	# Get quiz level data
	var collection: FirestoreCollection = Firebase.Firestore.collection("Level")
	var task: FirestoreTask = collection.get(quiz_level_id)
	var level_doc = yield(task, "task_finished")
	if not level_doc is FirestoreDocument:
		return Error.raise_invalid_parameter_error("'%s' is not a valid quiz level ID" % quiz_level_id)
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
		quiz_leve_id (String): Quiz's level ID.
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

func getChallengeByID(challengeID):
	var collection : FirestoreCollection = Firebase.Firestore.collection('Challenge')
	collection.get(challengeID)	
	var challenge : FirestoreDocument = yield(collection, "get_document")
	var result = challenge.doc_fields
	print(result)
	return result
	
# Updates the result for a challenge. 
func updateChallengeResult(challengeId, score, time, userId):
	var challenge = yield(getChallengeByID(challengeId), 'completed')
	
	var task: FirestoreTask
	var collection : FirestoreCollection;
	# Update record for challenger
	if userId == challenge['challengerID']:
		collection = Firebase.Firestore.collection('Challenge')
		task = collection.update(challengeId, {'challengerScore': score, 'challengerTime' : time})
	# Update record for challengee
	else:
		# Search challengee record using challengeID - Obtain the challengee_record id.
		var query : FirestoreQuery = FirestoreQuery.new()
		query.from('Challengee_Record')
		query.where('challengeID', FirestoreQuery.OPERATOR.EQUAL, challengeId)
		#query.where('challengeeID', FirestoreQuery.OPERATOR.EQUAL, userId)
	
		var query_task : FirestoreTask = Firebase.Firestore.query(query)
		var challengeeRecord = yield(query_task, 'task_finished')
		#get the recordId out
		var recordId = challengeeRecord[0].doc_name
		# Update the challengee record
		collection = Firebase.Firestore.collection('Challengee_Record')
		task = collection.update(recordId, {'challengeeScore': score, 'challengeeTime' : time, 'challengeStatus': 'completed'})
		
	yield(task, 'task_finished')
	print('Record Updated!')
