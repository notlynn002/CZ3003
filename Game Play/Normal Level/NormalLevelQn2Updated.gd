extends CanvasLayer

var aIsCorrect = false
var bIsCorrect = false
var cIsCorrect = false
var dIsCorrect = false
var ansCorrect = false

var currentUser

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
var normalLevelQn3 = preload("res://Game Play/Normal Level/NormalLevelQn3Updated.tscn").instance()

func _ready():
	$NormalLvlDoorOpen.hide()
	$Qn2/AnsCorrectMsg.hide()
	$Qn2/AnsWrongMsg.hide()
	$Qn2/NextButton.hide()
	$Qn2/AnsButton.hide()
	$Explanation.hide()
	
	currentUser = Globals.currUser['userId']
	
	var question = GlobalArray.question
	var qnBody = question["questionBody"]
	$QuestionBody.text = qnBody
	var options: Array = question["questionOptions"]
	levelId = question["levelID"]
	qnId = levelId + "-2"
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
	qnDescription = qnBank[1]
	GlobalArray.question = qnDescription
	#print(qnBank[1])
#	qnDescription = qnBank[1]
#	GlobalArray.question = qnDescription
	
func _on_A_pressed():
	if aIsCorrect:
		$Qn2/AnsCorrectMsg.show()
		ansCorrect = true
	else:
		$Qn2/AnsWrongMsg.show()	
	$Qn2/AnsButton.show()
	$Qn2/NextButton.show()
	submitAttempts = {
		"correct": ansCorrect,
		"duration": 60,
		"questionID": qnId
	}
	print(submitAttempts)
	attempts.append(submitAttempts)
	yield(towerBackend.submit_attempt(currentUser, attempts), "completed")

func _on_B_pressed():
	if bIsCorrect:
		$Qn2/AnsCorrectMsg.show()
		ansCorrect = true
	else:
		$Qn2/AnsWrongMsg.show()
	$Qn2/AnsButton.show()
	$Qn2/NextButton.show()
	submitAttempts = {
		"correct": ansCorrect,
		"duration": 60,
		"questionID": qnId
	}
	print(submitAttempts)
	attempts.append(submitAttempts)
	yield(towerBackend.submit_attempt(currentUser, attempts), "completed")
		
func _on_C_pressed():
	if cIsCorrect:
		$Qn2/AnsCorrectMsg.show()
		ansCorrect = true
	else:
		$Qn2/AnsWrongMsg.show()	
	$Qn2/AnsButton.show()
	$Qn2/NextButton.show()
	submitAttempts = {
		"correct": ansCorrect,
		"duration": 60,
		"questionID": qnId
	}
	print(submitAttempts)
	attempts.append(submitAttempts)
	yield(towerBackend.submit_attempt(currentUser, attempts), "completed")

func _on_D_pressed():
	if dIsCorrect:
		$Qn2/AnsCorrectMsg.show()
		ansCorrect = true
	else:
		$Qn2/AnsWrongMsg.show()
	$Qn2/AnsButton.show()
	$Qn2/NextButton.show()
	submitAttempts = {
		"correct": ansCorrect,
		"duration": 60,
		"questionID": qnId
	}
	print(submitAttempts)
	attempts.append(submitAttempts)
	yield(towerBackend.submit_attempt(currentUser, attempts), "completed")
		
func _on_ExplanationButton_pressed():
	$Explanation.show()
	$Explanation/Msg.text = explanation

func _on_ExitButton_pressed():
	$Explanation.hide()
	
func _on_NextButton_pressed():
	normalLevelQn3.init()
	get_tree().change_scene("res://Game Play/Normal Level/NormalLevelQn3Updated.tscn")
