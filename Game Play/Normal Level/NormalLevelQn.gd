extends CanvasLayer

var aIsCorrect = false
var bIsCorrect = false
var cIsCorrect = false
var dIsCorrect = false
var ansCorrect = false

var correctAnsPos
var correctAns
var solution
var explanation

var currentUser
var character

export (PackedScene) var King
export (PackedScene) var Archer
export (PackedScene) var Huntress
export (PackedScene) var Samurai

var timer = 0 # To start timer
var timeTaken
var pauseScreen = false

var levelId
var qnId
var questionBank: Array
var attempts: Array
var submitAttempts: Dictionary
var qnDescription: Dictionary

var towerBackend = preload("res://Backend/TowerBackend.tscn").instance()
var normalLevelQn2 = preload("res://Game Play/Normal Level/NormalLevelQn2Updated.tscn").instance()
var winMusic = preload("res://Audio/WinMusic.tscn").instance()

func _ready():
	GlobalArray.anwsers = []
	
	$NormalLvlDoorOpen.hide()
	$Qn1/AnsCorrectMsg.hide()
	$Qn1/AnsWrongMsg.hide()
	$Qn1/NextButton.hide()
	$Qn1/AnsButton.hide()
	$Explanation.hide()
	
	$WinMusic/Music.stream_paused = true
	$WinMusic/MuteButton.hide()
	$WinMusic/PlayButton.hide()
	
	$LoseMusic/Music.stream_paused = true
	$LoseMusic/MuteButton.hide()
	$LoseMusic/PlayButton.hide()
	
	character = Globals.currUser['character']
	if character == "king":
		var king = King.instance() # create an instance of king object
		# initialise starting position on map
		king.position.x = 50
		king.position.y = 841.167
		add_child(king) # add king to scene
	elif character == "archer":
		var archer = Archer.instance() # create an instance of archer object
		# initialise starting position on map
		archer.position.x = 50
		archer.position.y = 841.167
		add_child(archer) # add archer to scene
	elif character == "huntress":
		var huntress = Huntress.instance() # create an instance of huntress object
		# initialise starting position on map
		huntress.position.x = 50
		huntress.position.y = 841.167
		add_child(huntress) # add huntress to scene
	elif character == "samurai":
		var samurai = Samurai.instance() # create an instance of samurai object
		# initialise starting position on map
		samurai.position.x = 50
		samurai.position.y = 841.167
		add_child(samurai) # add samurai to scene
	
	currentUser = Globals.currUser['userId']
	
	var question = GlobalArray.question
	var qnBody = question["questionBody"]
	$QuestionBody.text = qnBody
	var options: Array = question["questionOptions"]
	levelId = question["levelID"]
	qnId = levelId + "-1"
	solution = question["questionSoln"]
	explanation = question["questionExplanation"]
	print(qnId)
	
	
	var A = options[0]
	var B = options[1]
	var C = options[2]
	var D = options[3]
	$A.text = A
	$B.text = B
	$C.text = C
	$D.text = D
	
	for i in range(0,4):
		if options[i] == solution:
			correctAnsPos = i
			break
			
	if correctAnsPos == 0:
		aIsCorrect = true
	elif correctAnsPos == 1:
		bIsCorrect = true
	elif correctAnsPos == 2:
		cIsCorrect = true
	else:
		dIsCorrect = true
	
	
func init(qnBank):
	print("Level1 question bank:", GlobalArray.questionBank)
	print(qnBank[0])
	qnDescription = qnBank[0]
	GlobalArray.question = qnDescription
	
	#var qnBody = qnDescription["questionBody"]
	#print(qnBody)

func _process(delta):
	if pauseScreen == false:
		timer += delta
		$Timer.text = "Timer: %ss" % stepify(timer,1)
#	elif timer <= 0:
#		$Timer.text = "Timer: %ss" % stepify(timer,1)
#		pauseScreen = true
		
func _on_A_pressed():
	$LevelMusic/Music.stop()
	$LevelMusic/MuteButton.hide()
	$LevelMusic/PlayButton.hide()
	if aIsCorrect:
		$Qn1/AnsCorrectMsg.show()
		ansCorrect = true
		$WinMusic/PlayButton.show()
		$WinMusic/Music.stream_paused = false
	else:
		$Qn1/AnsWrongMsg.show()
		$LoseMusic/PlayButton.show()
		$LoseMusic/Music.stream_paused = false
	$Qn1/AnsButton.show()
	$Qn1/NextButton.show()
	
	pauseScreen = true
	timeTaken = stepify(timer,1)
	submitAttempts = {
		"correct": ansCorrect,
		"duration": timeTaken,
		"questionID": qnId
	}
	print(submitAttempts)
	print("Time taken: ", timeTaken)
	GlobalArray.anwsers.append(submitAttempts)
	print(GlobalArray.anwsers)
	#yield(towerBackend.submit_attempt(currentUser, attempts), "completed")

func _on_B_pressed():
	$LevelMusic/Music.stop()
	if bIsCorrect:
		$Qn1/AnsCorrectMsg.show()
		ansCorrect = true
		$WinMusic/PlayButton.show()
		$WinMusic/Music.stream_paused = false
	else:
		$Qn1/AnsWrongMsg.show()
		$LoseMusic/PlayButton.show()
		$LoseMusic/Music.stream_paused = false
	$Qn1/AnsButton.show()
	$Qn1/NextButton.show()
	
	pauseScreen = true
	timeTaken = stepify(timer,1)
	submitAttempts = {
		"correct": ansCorrect,
		"duration": timeTaken,
		"questionID": qnId
	}
	print(submitAttempts)
	GlobalArray.anwsers.append(submitAttempts)
	#yield(towerBackend.submit_attempt(currentUser, attempts), "completed")
		
func _on_C_pressed():
	$LevelMusic/Music.stop()
	if cIsCorrect:
		$Qn1/AnsCorrectMsg.show()
		ansCorrect = true
		$WinMusic/PlayButton.show()
		$WinMusic/Music.stream_paused = false
	else:
		$Qn1/AnsWrongMsg.show()
		$LoseMusic/PlayButton.show()
		$LoseMusic/Music.stream_paused = false
#		$LoseMusic/Music.play()	
	$Qn1/AnsButton.show()
	$Qn1/NextButton.show()
	
	pauseScreen = true
	timeTaken = stepify(timer,1)
	submitAttempts = {
		"correct": ansCorrect,
		"duration": timeTaken,
		"questionID": qnId
	}
	print(submitAttempts)
	GlobalArray.anwsers.append(submitAttempts)
	#yield(towerBackend.submit_attempt(currentUser, attempts), "completed")

func _on_D_pressed():
	$LevelMusic/Music.stop()
	if dIsCorrect:
		$Qn1/AnsCorrectMsg.show()
		ansCorrect = true
		$WinMusic/PlayButton.show()
		$WinMusic/Music.stream_paused = false
	else:
		$Qn1/AnsWrongMsg.show()
		$LoseMusic/PlayButton.show()
		$LoseMusic/Music.stream_paused = false
	$Qn1/AnsButton.show()
	$Qn1/NextButton.show()
	
	pauseScreen = true
	timeTaken = stepify(timer,1)
	submitAttempts = {
		"correct": ansCorrect,
		"duration": timeTaken,
		"questionID": qnId
	}
	print(submitAttempts)
	GlobalArray.anwsers.append(submitAttempts)
	#yield(towerBackend.submit_attempt(currentUser, attempts), "completed")
		
func _on_ExplanationButton_pressed():
	$Explanation.show()
	$Explanation/Msg.text = explanation

func _on_ExitButton_pressed():
	$Explanation.hide()
	
func _on_NextButton_pressed():
	normalLevelQn2.init()
	get_tree().change_scene("res://Game Play/Normal Level/NormalLevelQn2Updated.tscn")
