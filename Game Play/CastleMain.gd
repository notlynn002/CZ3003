extends Node2D

var lvlCounter = 0
var prevscene
var clearlvl
var clearedLvl

var currentUser
var character
var towerId

export (PackedScene) var King
export (PackedScene) var Archer
export (PackedScene) var Huntress
export (PackedScene) var Samurai

var player

var lastLvlAttempted
var lvlInfo
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
	#load the character of the current user
	#$King.remove_and_skip()
	character = Globals.currUser['character']
	if character == "king":
		var king = King.instance() # create an instance of king object
		# initialise starting position on map
		king.position.x = 10
		king.position.y = 850.167
		add_child(king) # add king to scene
		player = king
	elif character == "archer":
		var archer = Archer.instance() # create an instance of archer object
		# initialise starting position on map
		archer.position.x = 10
		archer.position.y = 850.167
		add_child(archer) # add archer to scene
		player = archer
	elif character == "huntress":
		var huntress = Huntress.instance() # create an instance of huntress object
		# initialise starting position on map
		huntress.position.x = 10
		huntress.position.y = 850.167
		add_child(huntress) # add huntress to scene
		player = huntress
	elif character == "samurai":
		var samurai = Samurai.instance() # create an instance of samurai object
		# initialise starting position on map
		samurai.position.x = 10
		samurai.position.y = 850.167
		add_child(samurai) # add samurai to scene
		player = samurai
		
	$lvl1Stars/star1.hide() 
	$lvl1Stars/star2.hide()
	$lvl1Stars/star3.hide()
	$lvl2Stars/star1.hide()
	$lvl2Stars/star2.hide()
	$lvl2Stars/star3.hide()
	$lvl3Stars/star1.hide()
	$lvl3Stars/star2.hide()
	$lvl3Stars/star3.hide()
	$lvl4Stars/star1.hide()
	$lvl4Stars/star2.hide()
	$lvl4Stars/star3.hide()
	$lvl5Stars/star1.hide()
	$lvl5Stars/star2.hide()
	$lvl5Stars/star3.hide()
	$lvl6Stars/star1.hide()
	$lvl6Stars/star2.hide()
	$lvl6Stars/star3.hide()

	currentUser = Globals.currUser['userId']
	print(currentUser)
	if GlobalArray.nowAtTower == "Numbers":
		lvlInfo = yield(towerBackend.get_level_display_info(currentUser, "numbers-tower"), "completed")
		print(lvlInfo)
		#lastLvlAttempted = 0
	elif GlobalArray.nowAtTower == "Fraction":
		lvlInfo = yield(towerBackend.get_level_display_info(currentUser, "fraction-tower"), "completed")
	elif GlobalArray.nowAtTower == "Ratio":
		lvlInfo = yield(towerBackend.get_level_display_info(currentUser, "ratio-tower"), "completed")
	
	#separate last level attempted and no of correct answers
	lastLvlAttempted = lvlInfo["last_level"]
	correcNo = lvlInfo["correct_nos"]
	
	#open the door for levels attempted
	_door_Manager(lastLvlAttempted)
	print("correctNo:", correcNo)
	print("last lvl attempted:", lastLvlAttempted)
	_star_Manager(correcNo)
	
	for door in get_tree().get_nodes_in_group("open_doors"):
		door.connect("pressed", self, "_which_openDoor_pressed", [door])
		
#	for star in get_tree().get_nodes_in_group("hideStars"):
#		star.connect("pressed", self, "_hide_Stars", [star])
	
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
	#nowAtLevel = yield(towerBackend.get_last_level_attempted(currentUser, "numbers-tower"), "completed")#+1
	#nowAtLevel = 3 #need to change
	print("onNormalDoor last level attempted: ", lastLvlAttempted)
	nowAtLevel = lastLvlAttempted + 1
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
	currentLoc = player.get_position()
	GlobalArray.playerPosition = currentLoc
	
	#get the current level
	#nowAtLevel = yield(towerBackend.get_last_level_attempted(currentUser, "numbers-tower"), "completed")#+ 1
	#nowAtLevel = 5 #need to change
	print("onNormalDoor last level attempted: ", lastLvlAttempted)
	nowAtLevel = lastLvlAttempted + 1
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

func _door_Manager(lastLvlAttempted):#1
	var i = 1
	#open the attempted doors
	while i <= lastLvlAttempted:
		if i % 5 != 0:
			var closedDoor = get_node("Door" + String(i))
			closedDoor.hide()
		else:
			if correcNo[4] == 3:
				var closedDoor = get_node("Door" + String(i))
				closedDoor.hide()
			if correcNo[9] == 3:
				var closedDoor = get_node("Door" + String(i))
				closedDoor.hide()
		i += 1
	#lock the unattempted doors
	var j = lastLvlAttempted + 2
	while j <= 25:
		var lockedDoor = get_node("Door" + String(j))
		lockedDoor.disabled = true
		j += 1
	#open the blocks between laysers
	_block_Manager()

func _star_Manager(ansArray):
	correcNo = ansArray
	print(len(correcNo))
	var k = 0
	var showStars
	while k < len(correcNo):
		showStars = correcNo[k]
		if correcNo[k] > 0:
			var locNode = "lvl" + String(k+1) + "Stars/" + "star" + String(showStars)
			print(locNode)
			#stars = get_node("lvl1Stars/1star")
			var stars = get_node(locNode)
			stars.show()
		k += 1

func _block_Manager():
	if lastLvlAttempted == 5 && correcNo[4] == 3:
		$TowerBackground/TowerBricks22.remove_and_skip()
		$TowerBackground/BlockBrick.remove_and_skip()
	if lastLvlAttempted == 10 && correcNo[9] == 3:
		$TowerBackground2/BlockBrick.remove_and_skip()
	if lastLvlAttempted == 15: #&& correcNo[14] == 3:
		$TowerBackground2/TowerBricks22.remove_and_skip()
		$TowerBackground2/BlockBrick2.remove_and_skip()
	if lastLvlAttempted == 20: #&& correcNo[19] == 3:
		$TowerBackground3/BlockBrick.remove_and_skip()
	
func _which_openDoor_pressed(door):
	var door_name = door.name
	print(door_name)
	var doorName = door_name[8]
	print(doorName)
	
	if int(doorName) < 10:
		strNowAtLevel = "0" + doorName		
	
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
	
func _hide_Stars(star):
	var starToHide = star.name
	var nowHideStar = get_node(starToHide)
	print(nowHideStar)
#	nowHideStar.hide()
