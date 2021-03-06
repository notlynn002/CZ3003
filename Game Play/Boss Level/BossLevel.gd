extends CanvasLayer

export (PackedScene) var King
export (PackedScene) var Archer
export (PackedScene) var Huntress
export (PackedScene) var Samurai

# Declare variables
var currentUser
var character

var aIsCorrect = false
var bIsCorrect = false
var cIsCorrect = false
var dIsCorrect = false
var ansCorrect = false

var qn1Explanation = ""
var qn2Explanation = ""
var qn3Explanation = ""
var qn4Explanation = ""
var qn5Explanation = ""
var currentExplanation

var correctAnsPos
var correctAns
var solution
var explanation

var levelId
var qnId
var questionBank: Array
var submitAttempts: Dictionary
var qnDescription: Dictionary
var attempts: Array

var towerBackend = preload("res://Backend/TowerBackend.tscn").instance()

var timer = 600.0 # To be changed to 10.0 once testing has been completed
var timeTaken
var currentHealth = 3 setget update_bars
var qnNum = 1
var numOfCorrectAns = 0
var numOfAnsweredQuestions = 0
var pauseScreen = false
var toggleSolution = false

var player : KinematicBody2D = null

# Called when the node enters the scene tree for the first time.
func _ready():
	currentUser = Globals.currUser['userId']
	# get student's selected character from db 
	character = Globals.currUser['character']
	if character == "king":
		var king = King.instance() # create an instance of king object
		# initialise starting position on map
		king.position.x = 132.451
		king.position.y = 841.167
		add_child(king) # add king to scene
		player = king
	elif character == "archer":
		var archer = Archer.instance() # create an instance of archer object
		# initialise starting position on map
		archer.position.x = 132.451
		archer.position.y = 841.167
		add_child(archer) # add archer to scene
		player = archer
	elif character == "huntress":
		var huntress = Huntress.instance() # create an instance of huntress object
		# initialise starting position on map
		huntress.position.x = 132.451
		huntress.position.y = 841.167
		add_child(huntress) # add huntress to scene
		player = huntress
	elif character == "samurai":
		var samurai = Samurai.instance() # create an instance of samurai object
		# initialise starting position on map
		samurai.position.x = 132.451
		samurai.position.y = 841.167
		add_child(samurai) # add samurai to scene
		player = samurai
	player.set_physics_process(false)
	$AnimationManager.set_player(player)
	self.currentHealth = 3
	$Question/AnsMsg.hide()
	$Question/EndBossMsg.hide()
	$Question/NextButton.hide()
	$Question/NextText.hide()
	$Question/AnsButton.hide()
	$Question/AnsText.hide()
	$BossLvlDoorOpen.hide()
	$BossLvlSolution.hide()
	$GameOver.hide()
	$GameOver/QuitButton.hide()
	$GameOver/QuitButton/QuitText.hide()
	$GameOver/RetryButton.hide()
	$GameOver/RetryButton/RetryText.hide()

	
	prepare_question(qnNum)
	
func prepare_question(qnNo):
	aIsCorrect = false
	bIsCorrect = false
	cIsCorrect = false
	dIsCorrect = false
	ansCorrect = false
	var question = GlobalArray.questionBank[qnNo-1]
	var qnBody = question["questionBody"]
	var options: Array = question["questionOptions"]
	levelId = question["levelID"]
	qnId = levelId + "-" + str(qnNo)
	solution = question["questionSoln"]
	explanation = question["questionExplanation"]
	
	if qnNo == 1:
		qn1Explanation = explanation
	elif qnNo == 2:
		qn2Explanation = explanation
	elif qnNo == 3:
		qn3Explanation = explanation
	elif qnNo == 4:
		qn4Explanation = explanation
	elif qnNo == 5:
		qn5Explanation = explanation
	
	$Question/QnNum.text = "Question %s" % qnNo
	$Question/QnBody.text = qnBody
	
	var A = options[0]
	var B = options [1]
	var C = options[2]
	var D = options[3]
	$Question/Options/OptionA/OptionAText.text = A
	$Question/Options/OptionB/OptionBText.text = B
	$Question/Options/OptionC/OptionCText.text = C
	$Question/Options/OptionD/OptionDText.text = D
	
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
	pass

func update_bars(value):
	currentHealth = value

func correct_answer_animation():
	$Question/Options.visible = false
	yield($AnimationManager.action_player_attack(), "completed")
	$Question/Options.visible = true

func wrong_answer_animation():
	$Question/Options.visible = false
	yield($AnimationManager.action_monster_attack(), "completed")
	$Question/Options.visible = true

func player_win_animation():
	$Question/Options.visible = false
	yield($AnimationManager.action_player_kill_monster(), "completed")
	$Question/Options.visible = true

func player_lose_animation():
	$Question/Options.visible = false
	yield($AnimationManager.action_monster_kill_player(), "completed")
	$Question/Options.visible = true

func _on_OptionA_pressed():
	if pauseScreen != true:
		numOfAnsweredQuestions += 1
		if aIsCorrect:
			numOfCorrectAns += 1
			pauseScreen = true
			if numOfAnsweredQuestions < 5:
				yield(correct_answer_animation(), "completed")
			$Question/AnsMsg.show()
			$Question/AnsMsg/AnsMsgText.text = "That's correct!"
			$Question/NextButton.show()
			$Question/NextText.show()
			ansCorrect = true
			qnNum += 1
		else:
			currentHealth -= 1
			if currentHealth >0:
				pauseScreen = true
				yield(wrong_answer_animation(), "completed")
				$HealthBar.update_health(currentHealth)
				$Question/AnsMsg.show()
				$Question/AnsMsg/AnsMsgText.text = "That's wrong!"
				$Question/NextButton.show()
				$Question/NextText.show()
				qnNum += 1
			else:
				$HealthBar.update_health(currentHealth)
				game_ended("failbyhealth")
			
		timeTaken = 600 - stepify(timer,1)
		submitAttempts = {
			"correct": ansCorrect,
			"duration": timeTaken,
			"questionID": qnId
		}
		attempts.append(submitAttempts)
		if numOfCorrectAns >= 3 && timer > 0 && numOfAnsweredQuestions == 5:
			game_ended("success")

func _on_OptionB_pressed():
	if pauseScreen != true:
		numOfAnsweredQuestions += 1
		if bIsCorrect:
			numOfCorrectAns += 1
			pauseScreen = true
			if numOfAnsweredQuestions < 5:
				yield(correct_answer_animation(), "completed")
			$Question/AnsMsg.show()
			$Question/AnsMsg/AnsMsgText.text = "That's correct!"
			$Question/NextButton.show()
			$Question/NextText.show()
			ansCorrect = true
			qnNum += 1
		else:
			currentHealth -= 1
			if currentHealth >0:
				pauseScreen = true
				yield(wrong_answer_animation(), "completed")
				$HealthBar.update_health(currentHealth)
				$Question/AnsMsg.show()
				$Question/AnsMsg/AnsMsgText.text = "That's wrong!"
				$Question/NextButton.show()
				$Question/NextText.show()
				qnNum += 1
			else:
				$HealthBar.update_health(currentHealth)
				game_ended("failbyhealth")
			
		timeTaken = 600 - stepify(timer,1)
		submitAttempts = {
			"correct": ansCorrect,
			"duration": timeTaken,
			"questionID": qnId
		}
		attempts.append(submitAttempts)
		if numOfCorrectAns >= 3 && timer > 0 && numOfAnsweredQuestions == 5:
			game_ended("success")

func _on_OptionC_pressed():
	if pauseScreen != true:
		numOfAnsweredQuestions += 1
		if cIsCorrect:
			numOfCorrectAns += 1
			pauseScreen = true
			if numOfAnsweredQuestions < 5:
				yield(correct_answer_animation(), "completed")
			$Question/AnsMsg.show()
			$Question/AnsMsg/AnsMsgText.text = "That's correct!"
			$Question/NextButton.show()
			$Question/NextText.show()
			ansCorrect = true
			qnNum += 1
		else:
			currentHealth -= 1
			if currentHealth >0:
				pauseScreen = true
				yield(wrong_answer_animation(), "completed")
				$HealthBar.update_health(currentHealth)
				$Question/AnsMsg.show()
				$Question/AnsMsg/AnsMsgText.text = "That's wrong!"
				$Question/NextButton.show()
				$Question/NextText.show()
				qnNum += 1
			else:
				$HealthBar.update_health(currentHealth)
				game_ended("failbyhealth")
			
		timeTaken = 600 - stepify(timer,1)
		submitAttempts = {
			"correct": ansCorrect,
			"duration": timeTaken,
			"questionID": qnId
		}
		attempts.append(submitAttempts)
		if numOfCorrectAns >= 3 && timer > 0 && numOfAnsweredQuestions == 5:
			game_ended("success")

func _on_OptionD_pressed():
	if pauseScreen != true:
		numOfAnsweredQuestions += 1
		if dIsCorrect:
			numOfCorrectAns += 1
			pauseScreen = true
			if numOfAnsweredQuestions < 5:
				yield(correct_answer_animation(), "completed")
			$Question/AnsMsg.show()
			$Question/AnsMsg/AnsMsgText.text = "That's correct!"
			$Question/NextButton.show()
			$Question/NextText.show()
			ansCorrect = true
			qnNum += 1
		else:
			currentHealth -= 1
			if currentHealth >0:
				pauseScreen = true
				yield(wrong_answer_animation(), "completed")
				$HealthBar.update_health(currentHealth)
				$Question/AnsMsg.show()
				$Question/AnsMsg/AnsMsgText.text = "That's wrong!"
				$Question/NextButton.show()
				$Question/NextText.show()
				qnNum += 1
			else:
				$HealthBar.update_health(currentHealth)
				game_ended("failbyhealth")
			
		timeTaken = 600 - stepify(timer,1)
		submitAttempts = {
			"correct": ansCorrect,
			"duration": timeTaken,
			"questionID": qnId
		}
		attempts.append(submitAttempts)
		if numOfCorrectAns >= 3 && timer > 0 && numOfAnsweredQuestions == 5:
			game_ended("success")

func game_ended(condition):
	pauseScreen = true
	$Question/AnsMsg.hide()
	$Question/NextButton.hide()
	$Question/NextText.hide()
	$HealthBar.hide()
	if condition == "success":
		$Question/EndBossMsg.show()
		$Question/EndBossMsg/EndBossText.text = "You have passed the boss level!"
		$TowerBackground/Barrier1.hide()
		$TowerBackground/Barrier1/CollisionShape2D.remove_and_skip()
		$TowerBackground/Barrier2.hide()
		$TowerBackground/Barrier2/CollisionShape2D.remove_and_skip()
		$TowerBackground/Barrier3.hide()
		$TowerBackground/Barrier3/CollisionShape2D.remove_and_skip()
		
		yield(player_win_animation(), "completed")
		
#		$AnimationPlayer.play("slime-die")
#		yield($AnimationPlayer, "animation_finished")
		$BossLvlDoorClosed.hide()
		$BossLvlDoorOpen.show()
		$Question/AnsButton.show()
		$Question/AnsText.show()
		yield(towerBackend.submit_attempt(currentUser, attempts), "completed")
	elif condition == "failbyhealth":
		$GameOver.show()
		
		yield(player_lose_animation(), "completed")
#		$AnimationPlayer.play("slime-attack")
#		yield($AnimationPlayer, "animation_finished")
#		$AnimationPlayer.play("slime-idle")
		$GameOver/GameOverText.text = "YOU FAILED...\nYou have run out of lives"
		$GameOver/QuitButton.show()
		$GameOver/QuitButton/QuitText.show()
		$GameOver/RetryButton.show()
		$GameOver/RetryButton/RetryText.show()
	elif condition == "failbytime":
		$GameOver.show()
		
		yield(player_lose_animation(), "completed")
#		$AnimationPlayer.play("slime-attack")
#		yield($AnimationPlayer, "animation_finished")
#		$AnimationPlayer.play("slime-idle")
		$GameOver/GameOverText.text = "YOU FAILED...\nYou have run out of time"
		$GameOver/QuitButton.show()
		$GameOver/QuitButton/QuitText.show()
		$GameOver/RetryButton.show()
		$GameOver/RetryButton/RetryText.show()
		$GameOver/GameOverText.text = "YOU FAILED...\nYou have run out of time"
		$GameOver/QuitButton.show()
		$GameOver/QuitButton/QuitText.show()
		$GameOver/RetryButton.show()
		$GameOver/RetryButton/RetryText.show()

func _process(delta):
	
	if timer > 0 && pauseScreen == false:
		timer -= delta
		var time = int(timer)
		$Timer.text = "Timer: %02d:%02d" % [time/60, time%60]
	elif timer <= 0 && pauseScreen == false:
		var time = int(timer)
		$Timer.text = "Timer: %02d:%02d" % [time/60, time%60]
		game_ended("failbytime")
		pauseScreen = true
	
	$HealthBar.rect_position.x = player.get_node("AnimatedSprite").global_position.x - $HealthBar.rect_size.x*0.5
	

func _on_NextButton_pressed():
	$Question/AnsMsg.hide()
	$Question/NextButton.hide()
	$Question/NextText.hide()
	if qnNum <= 5:
		prepare_question(qnNum)
	pauseScreen = false
			

func _on_QuitButton_pressed():
	get_tree().change_scene("res://Game Play/StudentHomePage.tscn")
	get_node('/root/NormalLevel.tscn').queue_free()

func _on_RetryButton_pressed():
	get_tree().reload_current_scene()
	
func _on_AnsButton_pressed():
	if toggleSolution == false:
		toggleSolution = true
		$BossLvlSolution.show()
		if qn4Explanation == "":
			$BossLvlSolution/Qn4Explanation.hide()
			$BossLvlSolution/Qn5Explanation.hide()
		elif qn4Explanation != "" && qn5Explanation == "":
			$BossLvlSolution/Qn5Explanation.hide()
	else:
		toggleSolution = false
		$BossLvlSolution.hide()

func _on_Qn1Explanation_pressed():
	$BossLvlSolution/QnNumExplanation.text = "Question 1 Explanation"
	$BossLvlSolution/BossSolutionText.text = qn1Explanation

func _on_Qn2Explanation_pressed():
	$BossLvlSolution/QnNumExplanation.text = "Question 2 Explanation"
	$BossLvlSolution/BossSolutionText.text = qn2Explanation

func _on_Qn3Explanation_pressed():
	$BossLvlSolution/QnNumExplanation.text = "Question 3 Explanation"
	$BossLvlSolution/BossSolutionText.text = qn3Explanation

func _on_Qn4Explanation_pressed():
	$BossLvlSolution/QnNumExplanation.text = "Question 4 Explanation"
	$BossLvlSolution/BossSolutionText.text = qn4Explanation

func _on_Qn5Explanation_pressed():
	$BossLvlSolution/QnNumExplanation.text = "Question 5 Explanation"
	$BossLvlSolution/BossSolutionText.text = qn5Explanation
