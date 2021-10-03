extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var lvlCounter = 0
var prevscene
var clearlvl
var clearedLvl

func _ready():
	pass
	
func init(clearedLvl):
	clearlvl = clearedLvl
	var position_vector = GlobalArray.playerPosition
	get_node("King").set_position(position_vector)
	
	if GlobalArray.layerCount >= 1:
		if clearlvl >= 1:
			$Layer1Door1.hide()
		if clearlvl >= 2:
			$Layer1Door2.hide()
		if clearlvl >= 3:
			$Layer1Door3.hide()
		if clearlvl >= 4:
			$Layer1Door4.hide()
		if clearlvl >= 5:
			$Layer1Door5.hide()
			$TowerBackground/BlockBrick.hide()
			$TowerBackground/BlockBrick/CollisionShape2D.remove_and_skip()
	if GlobalArray.layerCount >= 2:
		print("Layer2 door 1: ", clearlvl)
		if clearlvl >= 6:
			$Layer2Door1.hide()
		if clearlvl >= 7:
			$Layer2Door2.hide()
		if clearlvl >= 8:
			$Layer2Door3.hide()
		if clearlvl >= 9:
			$Layer2Door4.hide()
		if clearlvl >= 10:
			$Layer2Door5.hide()
			$TowerBackground2/BlockBrick.hide()
			$TowerBackground2/BlockBrick/CollisionShape2D.remove_and_skip()
	if GlobalArray.layerCount >= 3:
		if clearlvl >= 11:
			$Layer3Door1.hide()
		if clearlvl >= 12:
			$Layer3Door2.hide()
		if clearlvl >= 13:
			$Layer3Door3.hide()
		if clearlvl >= 14:
			$Layer3Door4.hide()
		if clearlvl >= 15:
			$Layer3Door5.hide()
			$TowerBackground2/BlockBrick2.hide()
			$TowerBackground2/BlockBrick2/CollisionShape2D.remove_and_skip()
	if GlobalArray.layerCount >= 4:
		if clearlvl >= 16:
			$Layer4Door1.hide()
		if clearlvl >= 17:
			$Layer4Door2.hide()
		if clearlvl >= 18:
			$Layer4Door3.hide()
		if clearlvl >= 19:
			$Layer4Door4.hide()
		if clearlvl >= 20:
			$Layer4Door5.hide()
			$TowerBackground3/BlockBrick.hide()
			$TowerBackground3/BlockBrick/CollisionShape2D.remove_and_skip()
	if GlobalArray.layerCount >= 5:
		if clearlvl >= 21:
			$Layer5Door1.hide()
		if clearlvl >= 22:
			$Layer5Door2.hide()
		if clearlvl >= 23:
			$Layer5Door3.hide()
		if clearlvl >= 24:
			$Layer5Door4.hide()
		if clearlvl >= 25:
			$Layer5Door5.hide()
		
func _on_Door1_pressed():
	var currentLoc
	currentLoc = get_node("King").get_position()
	GlobalArray.playerPosition = currentLoc
	GlobalArray.L1Door1 = true
	get_tree().change_scene("res://Game Play/Normal Level/NormalLevelQn1.tscn")
	self.queue_free()
	
func _on_Door2_pressed():
	var currentLoc
	currentLoc = get_node("King").get_position()
	GlobalArray.playerPosition = currentLoc
	if GlobalArray.L1Door1:
		GlobalArray.L1Door2 = true
		get_tree().change_scene("res://Game Play/Normal Level/NormalLevelQn1.tscn")

func _on_Door3_pressed():
	var currentLoc
	currentLoc = get_node("King").get_position()
	GlobalArray.playerPosition = currentLoc
	if GlobalArray.L1Door2:
		GlobalArray.L1Door3 = true
		get_tree().change_scene("res://Game Play/Normal Level/NormalLevelQn1.tscn")

func _on_Door4_pressed():
	var currentLoc
	currentLoc = get_node("King").get_position()
	GlobalArray.playerPosition = currentLoc
	if GlobalArray.L1Door3:
		GlobalArray.L1Door4 = true
		get_tree().change_scene("res://Game Play/Normal Level/NormalLevelQn1.tscn")

func _on_Door5_pressed():
	var currentLoc
	currentLoc = get_node("King").get_position()
	GlobalArray.playerPosition = currentLoc
	if GlobalArray.L1Door4:
		get_tree().change_scene("res://Game Play/Boss Level/BossLevel.tscn")
