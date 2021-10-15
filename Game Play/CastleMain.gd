extends Node2D

var lvlCounter = 0
var prevscene
var clearlvl
var clearedLvl

var lastLvlAttempted
var nowAtLevel
var strNowAtLevel
var qnInDataBase
var towerLvlIdArray
var qnOfLevel: Array


var towerBackend = preload("res://Backend/TowerBackend.tscn").instance()
var normalLvlQn1 = preload("res://Game Play/Normal Level/NormalLevelQn1.tscn").instance()
var normalLvlQn2 = preload("res://Game Play/Normal Level/NormalLevelQn2Updated.tscn").instance()

func _ready():
	var i = 1
	#lastLvlAttempted = towerBackend.get_last_level_attempted("HjgDICIEdI4btnow8RP6", "numbers-tower")
	lastLvlAttempted = 2
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
	GlobalArray.L1Door1 = true
	
	#get the current level
	#nowAtLevel = towerBackend.get_last_level_attempted("HjgDICIEdI4btnow8RP6", "numbers-tower") + 1
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
	if GlobalArray.L1Door4:
		get_tree().change_scene("res://Game Play/Boss Level/BossLevel.tscn")

