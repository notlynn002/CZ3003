extends CanvasLayer

# Declare member variables here. Examples:
var questionList
var studentID
var id
var arenaType
var duration
var character

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
		
		
	# get list of qns from backend
	# get duration & convert to seconds
	# $Timer.set_wait_time(duration)
	$Timer.start()
	$TimerLabel.text = "Time left: " +  "%d:%02d" % [floor($Timer.time_left / 60), int($Timer.time_left) % 60]
	
	if arenaType == 'challenge':
		pass # get challenge by id
		 # get questions array
	elif arenaType == 'quiz':
		var quiz = yield(get_quiz(id), "completed")
		var questions = quiz['questions']
	
	# loop through qnList
	# for each qn, get qn details from backend
		# instance QuestionComponent
		# instance 4 AnswerComponent
		# save player's score in a global var
		
	# example to test implementation
	for i in 3:
		print(i)
		var qn = Question.instance()
		qn.init(str(i+1), 'this is a qn')
		
		var ans1 = Answer.instance()
		ans1.init('option 1', true)
		ans1.position.x = 60
		ans1.position.y = 450
		
		var ans2 = Answer.instance()
		ans2.init('option 2', false)
		ans2.position.x = 550
		ans2.position.y = 450
		
		var ans3 = Answer.instance()
		ans3.init('option 3', false)
		ans3.position.x = 1030
		ans3.position.y = 450
		
		var ans4 = Answer.instance()
		ans4.init('option 4', false)
		ans4.position.x = 1550
		ans4.position.y = 450
		
		add_child(qn)
		add_child(ans1)
		add_child(ans2)
		add_child(ans3)
		add_child(ans4)
		
		yield(Coroutines.await_any_signal([ans1, "answered", ans2, "answered", ans3, "answered", ans4, "answered"]), "completed")
		
	
	# when done with for loop
	# get remaining time
	var time_left = $Timer.time_left
	# check type & see if is quiz or challenge
	# save score and time to corresponsing db
	# navigate to home page
	
	print(str(Globals.score))
	
	
	
	
# warning-ignore:unused_argument
func _process(delta):
	$TimerLabel.text = "Time left: " +  "%d:%02d" % [floor($Timer.time_left / 60), int($Timer.time_left) % 60]
	
	# terminate game when time's up
	if $Timer.time_left <= 0:
		pass
		# check type & see if is quiz or challenge
		# save score and time to corresponsing db
		# navigate back to home page

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
