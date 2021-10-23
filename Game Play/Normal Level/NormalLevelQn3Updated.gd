extends CanvasLayer

var aIsCorrect = false
var bIsCorrect = false
var cIsCorrect = false
var dIsCorrect = false
var ansCorrect = false

export (PackedScene) var King
export (PackedScene) var Archer
export (PackedScene) var Huntress
export (PackedScene) var Samurai

var currentUser
var character

var timer = 0 # To start timer
var timeTaken
var pauseScreen = false

var correctAnsPos
var correctAns
var solution
var explanation

var questionBank
var levelId
var qnId
var attempts: Array
var submitAttempts: Dictionary
var qnDescription: Dictionary

var towerBackend = preload("res://Backend/TowerBackend.tscn").instance()

func _ready():
	
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
	$NormalLvlDoorOpen.hide()
	$Qn3/AnsCorrectMsg.hide()
	$Qn3/AnsWrongMsg.hide()
	$Qn3/AnsButton.hide()
	$Explanation.hide()
	
	currentUser = Globals.currUser['userId']
	
	var question = GlobalArray.question
	var qnBody = question["questionBody"]
	$QuestionBody.text = qnBody
	var options: Array = question["questionOptions"]
	levelId = question["levelID"]
	qnId = levelId + "-3"
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
	
	
func init():
	var qnBank = GlobalArray.questionBank
	qnDescription = qnBank[2]
	GlobalArray.question = qnDescription
	#print(qnBank[1])
#	qnDescription = qnBank[1]
#	GlobalArray.question = qnDescription
	
	#var qnBody = qnDescription["questionBody"]
	#print(qnBody)
	
#Checking Qn1
#func _on_Correct_pressed():
#	$Qn1/AnsCorrectMsg.show()
#	$Qn1/AnsButton.show()
#	$Qn1/NextButton.show()
#
#func _on_Wrong_pressed():
#	$Qn1/AnsWrongMsg.show()
#	$Qn1/AnsButton.show()
#	$Qn1/NextButton.show()

func _process(delta):
	if pauseScreen == false:
		timer += delta
		$Timer.text = "Timer: %ss" % stepify(timer,1)
	
func _on_A_pressed():
	if aIsCorrect:
		$Qn3/AnsCorrectMsg.show()
		ansCorrect = true
	else:
		$Qn3/AnsWrongMsg.show()	
	$Qn3/AnsButton.show()
	
	pauseScreen = true
	timeTaken = stepify(timer,1)
	submitAttempts = {
		"correct": ansCorrect,
		"duration": timeTaken,
		"questionID": qnId
	}
	$NormalLvlDoorOpen.show()
	print(submitAttempts)
	GlobalArray.anwsers.append(submitAttempts)
	print(GlobalArray.anwsers)
	yield(towerBackend.submit_attempt(currentUser, GlobalArray.anwsers), "completed")

func _on_B_pressed():
	if bIsCorrect:
		$Qn3/AnsCorrectMsg.show()
		ansCorrect = true
	else:
		$Qn3/AnsWrongMsg.show()
	$Qn3/AnsButton.show()
	
	pauseScreen = true
	timeTaken = stepify(timer,1)
	submitAttempts = {
		"correct": ansCorrect,
		"duration": timeTaken,
		"questionID": qnId
	}
	$NormalLvlDoorOpen.show()
	print(submitAttempts)
	GlobalArray.anwsers.append(submitAttempts)
	yield(towerBackend.submit_attempt(currentUser, GlobalArray.anwsers), "completed")
		
func _on_C_pressed():
	if cIsCorrect:
		$Qn3/AnsCorrectMsg.show()
		ansCorrect = true
	else:
		$Qn3/AnsWrongMsg.show()	
	$Qn3/AnsButton.show()
	
	pauseScreen = true
	timeTaken = stepify(timer,1)
	submitAttempts = {
		"correct": ansCorrect,
		"duration": timeTaken,
		"questionID": qnId
	}
	$NormalLvlDoorOpen.show()
	print(submitAttempts)
	GlobalArray.anwsers.append(submitAttempts)
	yield(towerBackend.submit_attempt(currentUser, GlobalArray.anwsers), "completed")

func _on_D_pressed():
	if dIsCorrect:
		$Qn3/AnsCorrectMsg.show()
		ansCorrect = true
	else:
		$Qn3/AnsWrongMsg.show()
	$Qn3/AnsButton.show()
	
	pauseScreen = true
	timeTaken = stepify(timer,1)
	submitAttempts = {
		"correct": ansCorrect,
		"duration": timeTaken,
		"questionID": qnId
	}
	$NormalLvlDoorOpen.show()
	print(submitAttempts)
	GlobalArray.anwsers.append(submitAttempts)
	yield(towerBackend.submit_attempt(currentUser, GlobalArray.anwsers), "completed")
		
func _on_ExplanationButton_pressed():
	$Explanation.show()
	$Explanation/Msg.text = explanation

func _on_ExitButton_pressed():
	$Explanation.hide()
	
func _on_Open_Door_pressed():
	#var TheRoot = get_node("/root")
	#$King.remove_and_skip()
#	var NextScene = load("res://Game Play/Normal Level/NormalLevel.tscn").instance()
#	var root = get_tree().root
#	root.add_child(NextScene)
	get_tree().change_scene("res://Game Play/Normal Level/NormalLevel.tscn")
