extends Node2D

var lvlCounter = 0
var prevscene
var clearlvl
var clearedLvl

var lastLvlAttempted
var correcNo: Array
var nowAtLevel
var strNowAtLevel
var qnInDataBase
var towerLvlIdArray
var qnOfLevel: Array


var towerBackend = preload("res://Backend/TowerBackend.tscn").instance()
var normalLvlQn1 = preload("res://Game Play/Normal Level/NormalLevelQn1.tscn").instance()
var normalLvlQn2 = preload("res://Game Play/Normal Level/NormalLevelQn2Updated.tscn").instance()
var bossLvl = preload("res://Game Play/Boss Level/BossLevel.tscn").instance()

func _ready():
	$lvl1Stars/star1.hide()
	$lvl1Stars/star2.hide()
	$lvl1Stars/star3.hide()
	#$lvl2Stars.hide()
	var i = 1
	if GlobalArray.nowAtTower == "Numbers":
		#lastLvlAttempted = yield(towerBackend.get_last_level_attempted("HjgDICIEdI4btnow8RP6", "numbers-tower"), "completed")
		lastLvlAttempted = 2
		#correctNo = yield(towerBackend.get_correct_No("HjgDICIEdI4btnow8RP6", "numbers-tower"), "completed")
		#correcNo = [1]
	
	#open the door for levels attempted
	while i <= lastLvlAttempted:
		var closedDoor = get_node("Door" + String(i))
		closedDoor.hide()
		i += 1
	#lock the unattempted doors
	var j = lastLvlAttempted + 2
	while j <= 25:
		var lockedDoor = get_node("Door" + String(j))
		lockedDoor.disabled = true
		j += 1
	#shows the stars
	#_star_Manager(correcNo)
	correcNo = [2]
	print(len(correcNo))
	var k = 0
	var showStars
	while k < len(correcNo):
		showStars = correcNo[k]
		var locNode = "lvl" + String(k+1) + "Stars/" + "star" + String(showStars)
		print(locNode)
		#stars = get_node("lvl1Stars/1star")
		var stars = get_node(locNode)
		stars.show()
		k += 1
	
func init(nowAtTower):
	clearlvl = clearedLvl
	#var position_vector = GlobalArray.playerPosition
	#get_node("King").set_position(position_vector)
	print(nowAtTower)
	
	GlobalArray.nowAtTower = nowAtTower
	if nowAtTower == "Numbers":
		var level = yield(towerBackend.get_level_for_tower("numbers-tower"), 'completed')
		
func _on_NormalLevelDoor_pressed():
	var currentLoc
	currentLoc = get_node("King").get_position()
	GlobalArray.playerPosition = currentLoc
	
	#get the current level
	#nowAtLevel = yield(towerBackend.get_last_level_attempted("HjgDICIEdI4btnow8RP6", "numbers-tower"), "completed") + 1
	nowAtLevel = 3 #need to change
	if nowAtLevel < 10:
		strNowAtLevel = "0" + String(nowAtLevel)
	else:
		strNowAtLevel = String(nowAtLevel)		
	
	#load qn from database
	if GlobalArray.nowAtTower == "Numbers":
		qnInDataBase = "numbers-" + strNowAtLevel
	elif GlobalArray.nowAtTower == "Fraction":
		qnInDataBase = "fraction-" + strNowAtLevel
	elif GlobalArray.nowAtTower == "Ratio":
		qnInDataBase = "ratio-" + strNowAtLevel
	
	#update & load the next scene 
	qnOfLevel = yield(TowerBackend.get_questions_by_level(qnInDataBase),"completed")
	GlobalArray.questionBank = qnOfLevel
	normalLvlQn1.init(qnOfLevel)
	get_tree().change_scene("res://Game Play/Normal Level/NormalLevelQn1.tscn")

func _on_BossLevelDoor_pressed():
	var currentLoc
	currentLoc = get_node("King").get_position()
	GlobalArray.playerPosition = currentLoc
	
	#get the current level
	#nowAtLevel = yield(towerBackend.get_last_level_attempted("HjgDICIEdI4btnow8RP6", "numbers-tower"), "completed") + 1
	nowAtLevel = 5 #need to change
	if nowAtLevel < 10:
		strNowAtLevel = "0" + String(nowAtLevel)
	else:
		strNowAtLevel = String(nowAtLevel)		
	
	#load qn from database
	if GlobalArray.nowAtTower == "Numbers":
		qnInDataBase = "numbers-" + strNowAtLevel
	elif GlobalArray.nowAtTower == "Fraction":
		qnInDataBase = "fraction-" + strNowAtLevel
	elif GlobalArray.nowAtTower == "Ratio":
		qnInDataBase = "ratio-" + strNowAtLevel
	
	#update & load the next scene 
	qnOfLevel = yield(TowerBackend.get_questions_by_level(qnInDataBase),"completed")
	GlobalArray.questionBank = qnOfLevel
	bossLvl.init(qnOfLevel)
	get_tree().change_scene("res://Game Play/Boss Level/BossLevel.tscn")

func _star_Manager(ansArray):
	print("here")
	correcNo = ansArray
	print(correcNo)
	var i = 0
	var showStars
	while i < len(correcNo):
		print("while loop")
		showStars = correcNo[i]
		var locNode = "lvl" + String(i+1) + "Stars/" + String(showStars) + "star"
		print(locNode)
		#stars = get_node("lvl1Stars/1star")
		var stars = get_node(locNode)
		stars.show()
		i += 1
