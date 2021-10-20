extends CanvasLayer

# Declare member variables here. Examples:
var studentID
var id
var arenaType
var duration
var character
var questions
var challenge
var quiz
var timer_started: bool = false # true if timer has been started, false otherwise
var attempt_submitted: bool = false # true if attempt for quiz/challenge has been submitted, false otherwise


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
	$ScorePopup.hide()
	Firebase.Auth.login_with_email_and_password("admin@gmail.com", "cz3003ssad")
	
	if arenaType == 'challenge':
		challenge = yield(ChallengeBackend.getChallengeByID(id), "completed")
		$Loading.hide()
		questions = challenge['questionList']
		duration = 600
	elif arenaType == 'quiz':
		quiz = yield(QuizBackend.get_quiz(id), "completed")
		questions = quiz['questions']
		duration = quiz['levelDuration']
		$Loading.hide()
#		var currAttempts = yield(QuizBackend.check_max_attempt_reached(Globals.currUser.userId, id), "completed") # this fxn is not working
#		if currAttempts:
#			$Popup.show() 
#			$Game.hide()
	
	# reset score & attempt
	Globals.score = 0
	Globals.attempt = []

	# get student's selected character from db
	character = yield(ProfileBackend.getCharacter(Globals.currUser.userId), "completed")
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
	
	
				
	$Background/Timer.set_wait_time(duration)
	$Background/Timer.start()
	timer_started = true
	$Background/TimerLabel.text = "Time left: " +  "%d:%02d" % [floor($Background/Timer.time_left / 60), int($Background/Timer.time_left) % 60]
	print(questions)
	for i in range(questions.size()):
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
		
		remove_child(qn)
		remove_child(ans1)
		remove_child(ans2)
		remove_child(ans3)
		remove_child(ans4)
	
	# when done with for loop
	# get remaining time
	var time_left = $Background/Timer.time_left
	var time_taken = int((duration-time_left))
	$Background/Timer.stop()
	# check type & see if is quiz or challenge
	# save score and time to corresponsing db
	# navigate to home page
	if arenaType == 'quiz':
		var attempt_record = {}
		for i in range(Globals.attempt.size()):
			attempt_record[Globals.attempt[i][0]] = Globals.attempt[i][1]
		yield(QuizBackend.submit_quiz_attempt(Globals.currUser.userId, id, time_taken, attempt_record), "completed")
		print(attempt_record)

	elif arenaType == 'challenge':
		print(time_taken)
		yield(ChallengeBackend.updateChallengeResult(id, Globals.score, time_taken, Globals.currUser.userId), "completed")
		
	# can display score before navigating back
	$ScorePopup/ScoreLabel.text = 'Score: ' + str(Globals.score) + '/' + str(len(questions))
	$ScorePopup/TimeLabel.text = 'Timing: ' + "%d:%02d" % [floor((duration-time_left) / 60), int((duration-time_left)) % 60]
	$ScorePopup.show()
	
# warning-ignore:unused_argument
func _process(delta):
	$Background/TimerLabel.text = "Time left: " +  "%d:%02d" % [floor($Background/Timer.time_left / 60), int($Background/Timer.time_left) % 60]
	
	# terminate game when time's up
	if timer_started and ($Background/Timer.time_left <= 0) and (not attempt_submitted):
		if arenaType == 'quiz':
			var attempt_record = {}
			for i in range(Globals.attempt.size()):
				attempt_record[Globals.attempt[i][0]] = Globals.attempt[i][1]
				
			yield(QuizBackend.submit_quiz_attempt(Globals.currUser.userId, id, 0, attempt_record), "completed")
		elif arenaType == 'challenge':
			yield(ChallengeBackend.updateChallengeResult(id, Globals.score, 0, Globals.currUser.userId), "completed")
		attempt_submitted = true
			
func _on_CloseButton_pressed():
	var root = get_tree().root
	var homePage = load("res://Game Play/StudentHomePage.tscn").instance()
	root.add_child(homePage)
	self.queue_free()
	get_node('/root/ArenaPage').queue_free()

	
	


func _on_CloseScorePopupButton_pressed():
	get_tree().change_scene("res://Game Play/StudentHomePage.tscn")
	self.queue_free()
	get_node('/root/ArenaPage').queue_free()
