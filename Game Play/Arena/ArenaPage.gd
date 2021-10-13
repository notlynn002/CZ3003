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


func on_answered():
	pass
