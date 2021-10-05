extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var timer = 10.0	# To be changed to 600.0 once testing has been completed
var current_health = 3 setget update_bars
var question_num = 1
var correct_ans = 0
var pause_timer = false
var game_over = false
var toggle_solution = false


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = false
	self.current_health = 3
	$Question/QnNum.text = "Question %s" % question_num
	$Question/AnsMsg.hide()
	$Question/EndBossMsg.hide()
	$Question/NextButton.hide()
	$Question/AnsButton.hide()
	$BossLvlDoorOpen.hide()
	$BossLvlSolution.hide()
	$GameOver.hide()
	$GameOver/QuitButton.hide()
	$GameOver/QuitButton/QuitLabel.hide()
	$GameOver/RetryButton.hide()
	$GameOver/RetryButton/RetryLabel.hide()
	
	
func update_bars(value):
	current_health = value
	
		
func _on_Correct_pressed():
	correct_ans += 1
	if correct_ans < 3 && timer > 0:
		get_tree().paused = true
		pause_timer = true
		$Question/AnsMsg.show()
		$Question/AnsMsg/AnsMsgLabel.text = "That's correct!"
		$Question/NextButton.show()
	elif correct_ans >= 3 && timer > 0:
		get_tree().paused = true
		pause_timer = true
		game_over = true
		$Question/EndBossMsg.show()
		$Question/EndBossMsg/EndBossLabel.text = "You have passed the boss level!"
		$HealthBar.hide()
		$TowerBackground/Barrier1.hide()
		$TowerBackground/Barrier1/CollisionShape2D.remove_and_skip()
		$TowerBackground/Barrier2.hide()
		$TowerBackground/Barrier2/CollisionShape2D.remove_and_skip()
		$BossLvlDoorClosed/CollisionShape2D.remove_and_skip()
		$BossLvlDoorOpen.show()
		$Question/AnsButton.show()
	question_num += 1


func _on_Wrong_pressed():
	current_health -= 1
	$HealthBar.update_health(current_health)
	if current_health > 0:
		get_tree().paused = true
		pause_timer = true
		$Question/AnsMsg.show()
		$Question/AnsMsg/AnsMsgLabel.text = "That's wrong!"
		$Question/NextButton.show()
		question_num += 1
	elif current_health == 0:
		get_tree().paused = true
		pause_timer = true
		game_over = true
		$GameOver.show()
		$GameOver/GameOverLabel.text = "YOU FAILED...\nYou have run out of lives"
		$GameOver/QuitButton.show()
		$GameOver/QuitButton/QuitLabel.show()
		$GameOver/RetryButton.show()
		$GameOver/RetryButton/RetryLabel.show()


func _process(delta):
	if timer > 0 && pause_timer == false:
		timer -= delta
		$Timer.text = "Timer: %ss" % stepify(timer,1)
	elif timer <= 0:
		$Timer.text = "Timer: %ss" % stepify(timer,1)
		get_tree().paused = true
		pause_timer = true
		game_over = true
		$GameOver.show()
		$GameOver/GameOverLabel.text = "YOU FAILED...\nYou have run out of time"
		$GameOver/QuitButton.show()
		$GameOver/QuitButton/QuitLabel.show()
		$GameOver/RetryButton.show()
		$GameOver/RetryButton/RetryLabel.show()


func _on_NextButton_pressed():
	get_tree().paused = false
	$Question/AnsMsg.hide()
	$Question/NextButton.hide()# Replace with function body.
	$Question/QnNum.text = "Question %s" % question_num
	pause_timer = false
			

func _on_AnsButton_pressed():
	if toggle_solution == false:
		toggle_solution = true
		$BossLvlSolution.show()
		$BossLvlSolution/BossSolutionLabel.text = "Solution for Boss Level..."
	else:
		toggle_solution = false
		$BossLvlSolution.hide()


func _on_BossLvlDoorOpen_pressed():
	get_tree().paused = false
	var NextScene = preload("res://Game Play/Normal Level/NormalLevel.tscn").instance()
	var clearedLvl
	GlobalArray.levelCount += 1
	print(GlobalArray.levelCount)
	
	if GlobalArray.nowAtLvl == 1:
		clearedLvl = GlobalArray.levelCount
		GlobalArray.L1Door1 = true
		NextScene.init(clearedLvl)
		add_child(NextScene)
	elif GlobalArray.nowAtLvl == 2:
		clearedLvl = GlobalArray.levelCount
		NextScene.init(clearedLvl)
		add_child(NextScene)
	elif GlobalArray.nowAtLvl == 3:
		clearedLvl = GlobalArray.levelCount
		NextScene.init(clearedLvl)
		add_child(NextScene)
	elif GlobalArray.nowAtLvl == 4:
		clearedLvl = GlobalArray.levelCount
		NextScene.init(clearedLvl)
		add_child(NextScene)
	else:
		clearedLvl = GlobalArray.levelCount
		NextScene.init(clearedLvl)
		add_child(NextScene)
		GlobalArray.nowAtLvl = 0
		
	print(GlobalArray.layerCount)
	if GlobalArray.levelCount == 5:
		GlobalArray.layerCount += 1
	elif GlobalArray.levelCount == 10:
		GlobalArray.layerCount += 1
	elif GlobalArray.levelCount == 15:
		GlobalArray.layerCount += 1
	elif GlobalArray.levelCount == 20:
		GlobalArray.layerCount += 1
	elif GlobalArray.levelCount == 25:
		GlobalArray.layerCount += 1


func _on_QuitButton_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://Game Play/StudentHomePage.tscn")


func _on_RetryButton_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()