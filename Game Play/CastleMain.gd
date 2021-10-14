extends Node2D

var lvlCounter = 0
var prevscene
var clearlvl
var clearedLvl
var towerLvlIdArray
var qnOfLevel: Array


var towerBackend = preload("res://Backend/TowerBackend.tscn").instance()
var normalLvlQn1 = preload("res://Game Play/Normal Level/NormalLevelQn1.tscn").instance()
var normalLvlQn2 = preload("res://Game Play/Normal Level/NormalLevelQn2Updated.tscn").instance()

func _ready():
	pass
	
func init(nowAtTower):
	clearlvl = clearedLvl
	var position_vector = GlobalArray.playerPosition
	#get_node("King").set_position(position_vector)
	print(nowAtTower)
	GlobalArray.nowAtTower = nowAtTower
	if nowAtTower == "Numbers":
		var level = yield(towerBackend.get_level_for_tower("numbers-tower"), 'completed')
			
	
#	if GlobalArray.layerCount >= 1:
#		if clearlvl >= 1:
#			$Layer1Door1.hide()
#		if clearlvl >= 2:
#			$Layer1Door2.hide()
#		if clearlvl >= 3:
#			$Layer1Door3.hide()
#		if clearlvl >= 4:
#			$Layer1Door4.hide()
#		if clearlvl >= 5:
#			$Layer1Door5.hide()
#			$TowerBackground/BlockBrick.hide()
#			$TowerBackground/BlockBrick/CollisionShape2D.remove_and_skip()
#	if GlobalArray.layerCount >= 2:
#		print("Layer2 door 1: ", clearlvl)
#		if clearlvl >= 6:
#			$Layer2Door1.hide()
#		if clearlvl >= 7:
#			$Layer2Door2.hide()
#		if clearlvl >= 8:
#			$Layer2Door3.hide()
#		if clearlvl >= 9:
#			$Layer2Door4.hide()
#		if clearlvl >= 10:
#			$Layer2Door5.hide()
#			$TowerBackground2/BlockBrick.hide()
#			$TowerBackground2/BlockBrick/CollisionShape2D.remove_and_skip()
#	if GlobalArray.layerCount >= 3:
#		if clearlvl >= 11:
#			$Layer3Door1.hide()
#		if clearlvl >= 12:
#			$Layer3Door2.hide()
#		if clearlvl >= 13:
#			$Layer3Door3.hide()
#		if clearlvl >= 14:
#			$Layer3Door4.hide()
#		if clearlvl >= 15:
#			$Layer3Door5.hide()
#			$TowerBackground2/BlockBrick2.hide()
#			$TowerBackground2/BlockBrick2/CollisionShape2D.remove_and_skip()
#	if GlobalArray.layerCount >= 4:
#		if clearlvl >= 16:
#			$Layer4Door1.hide()
#		if clearlvl >= 17:
#			$Layer4Door2.hide()
#		if clearlvl >= 18:
#			$Layer4Door3.hide()
#		if clearlvl >= 19:
#			$Layer4Door4.hide()
#		if clearlvl >= 20:
#			$Layer4Door5.hide()
#			$TowerBackground3/BlockBrick.hide()
#			$TowerBackground3/BlockBrick/CollisionShape2D.remove_and_skip()
#	if GlobalArray.layerCount >= 5:
#		if clearlvl >= 21:
#			$Layer5Door1.hide()
#		if clearlvl >= 22:
#			$Layer5Door2.hide()
#		if clearlvl >= 23:
#			$Layer5Door3.hide()
#		if clearlvl >= 24:
#			$Layer5Door4.hide()
#		if clearlvl >= 25:
#			$Layer5Door5.hide()
		
func _on_Door1_pressed():
	var currentLoc
	currentLoc = get_node("King").get_position()
	GlobalArray.playerPosition = currentLoc
	GlobalArray.L1Door1 = true
	var nowAtLevel = 1 #need to change
	#towerBackend.get_last_level_attempted("XKwVQ9EqJ7xjEhHoPr0A", "numbers-tower")
	if GlobalArray.nowAtTower == "Numbers":
		if nowAtLevel <= 5:
			qnOfLevel = yield(TowerBackend.get_questions_by_level("numbers-01"),"completed")
		elif nowAtLevel > 5 && nowAtLevel <= 10:
			qnOfLevel = yield(TowerBackend.get_questions_by_level("numbers-06"),"completed")
		elif nowAtLevel > 10 && nowAtLevel <= 15:
			qnOfLevel = yield(TowerBackend.get_questions_by_level("numbers-011"),"completed")
		elif nowAtLevel > 15 && nowAtLevel <= 20:
			qnOfLevel = yield(TowerBackend.get_questions_by_level("numbers-16"),"completed")
		else:
			qnOfLevel =  yield(TowerBackend.get_questions_by_level("numbers-21"),"completed")
		GlobalArray.questionBank = qnOfLevel
		normalLvlQn1.init(qnOfLevel)
#	elif GlobalArray.nowAtTower == "Fractions":
#		var qnOfLevel = towerBackend.get_questions_by_level()
	get_tree().change_scene("res://Game Play/Normal Level/NormalLevelQn1.tscn")
	self.queue_free()
	
	
	
func _on_Door2_pressed():
	var currentLoc
	currentLoc = get_node("King").get_position()
	GlobalArray.playerPosition = currentLoc
	var nowAtLevel = 2 #need to change
	#towerBackend.get_last_level_attempted("XKwVQ9EqJ7xjEhHoPr0A", "numbers-tower")
	if GlobalArray.nowAtTower == "Numbers":
		if nowAtLevel <= 5:
			qnOfLevel = yield(TowerBackend.get_questions_by_level("numbers-02"),"completed")
		elif nowAtLevel > 5 && nowAtLevel <= 10:
			qnOfLevel = yield(TowerBackend.get_questions_by_level("numbers-07"),"completed")
		elif nowAtLevel > 10 && nowAtLevel <= 15:
			qnOfLevel = yield(TowerBackend.get_questions_by_level("numbers-12"),"completed")
		elif nowAtLevel > 15 && nowAtLevel <= 20:
			qnOfLevel = yield(TowerBackend.get_questions_by_level("numbers-17"),"completed")
		else:
			qnOfLevel = yield(TowerBackend.get_questions_by_level("numbers-22"),"completed")
		GlobalArray.questionBank = qnOfLevel
		normalLvlQn1.init(qnOfLevel)
	
	get_tree().change_scene("res://Game Play/Normal Level/NormalLevelQn1.tscn")
	self.queue_free()
#	if GlobalArray.L1Door1:
#		GlobalArray.L1Door2 = true
#	elif GlobalArray.nowAtTower == "Fractions":
#		var qnOfLevel = towerBackend.get_questions_by_level()

func _on_Door3_pressed():
	var currentLoc
	currentLoc = get_node("King").get_position()
	GlobalArray.playerPosition = currentLoc
#	if GlobalArray.L1Door2:
#		GlobalArray.L1Door3 = true
#		get_tree().change_scene("res://Game Play/Normal Level/NormalLevelQn1.tscn")
	var nowAtLevel = 3 #need to change
	#towerBackend.get_last_level_attempted("XKwVQ9EqJ7xjEhHoPr0A", "numbers-tower")
	if GlobalArray.nowAtTower == "Numbers":
		if nowAtLevel <= 5:
			qnOfLevel = yield(TowerBackend.get_questions_by_level("numbers-03"),"completed")
		elif nowAtLevel > 5 && nowAtLevel <= 10:
			qnOfLevel = yield(TowerBackend.get_questions_by_level("numbers-08"),"completed")
		elif nowAtLevel > 10 && nowAtLevel <= 15:
			qnOfLevel = yield(TowerBackend.get_questions_by_level("numbers-13"),"completed")
		elif nowAtLevel > 15 && nowAtLevel <= 20:
			qnOfLevel = yield(TowerBackend.get_questions_by_level("numbers-18"),"completed")
		else:
			qnOfLevel = yield(TowerBackend.get_questions_by_level("numbers-23"),"completed")
		GlobalArray.questionBank = qnOfLevel
		normalLvlQn1.init(qnOfLevel)
	get_tree().change_scene("res://Game Play/Normal Level/NormalLevelQn1.tscn")
	self.queue_free()
	

func _on_Door4_pressed():
	var currentLoc
	currentLoc = get_node("King").get_position()
	GlobalArray.playerPosition = currentLoc
#	if GlobalArray.L1Door3:
#		GlobalArray.L1Door4 = true
#		get_tree().change_scene("res://Game Play/Normal Level/NormalLevelQn1.tscn")
	var nowAtLevel = 4 #need to change
	#towerBackend.get_last_level_attempted("XKwVQ9EqJ7xjEhHoPr0A", "numbers-tower")
	if GlobalArray.nowAtTower == "Numbers":
		if nowAtLevel <= 5:
			qnOfLevel = yield(TowerBackend.get_questions_by_level("numbers-04"),"completed")
		elif nowAtLevel > 5 && nowAtLevel <= 10:
			qnOfLevel = yield(TowerBackend.get_questions_by_level("numbers-09"),"completed")
		elif nowAtLevel > 10 && nowAtLevel <= 15:
			qnOfLevel = yield(TowerBackend.get_questions_by_level("numbers-14"),"completed")
		elif nowAtLevel > 15 && nowAtLevel <= 20:
			qnOfLevel = yield(TowerBackend.get_questions_by_level("numbers-19"),"completed")
		else:
			qnOfLevel = yield(TowerBackend.get_questions_by_level("numbers-24"),"completed")
		GlobalArray.questionBank = qnOfLevel
		normalLvlQn1.init(qnOfLevel)
	get_tree().change_scene("res://Game Play/Normal Level/NormalLevelQn1.tscn")
	self.queue_free()

func _on_Door5_pressed():
	var currentLoc
	currentLoc = get_node("King").get_position()
	GlobalArray.playerPosition = currentLoc
	if GlobalArray.L1Door4:
		get_tree().change_scene("res://Game Play/Boss Level/BossLevel.tscn")
