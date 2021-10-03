extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var lvlCounter = 0
var prevscene
var clearlvl
var clearedLvl

var door1Opened = false
var door2Opened = false
var door3Opened = false
var door4Opened = false

var Qn1Answered = false
var Qn2Answered = false
var Qn3Answered = false
var Qn4Answered = false
var Qn5Answered = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func init(clearedLvl):
	clearlvl = clearedLvl
	if GlobalArray.layerCount == 1:
		if clearlvl == 1:
			$Layer1Door1.hide()
		elif clearedLvl == 2:
			$Layer1Door1.hide()
			$Layer1Door2.hide()
		elif clearedLvl == 3:
			$Layer1Door1.hide()
			$Layer1Door2.hide()
			$Layer1Door3.hide()
		elif clearedLvl == 4:
			$Layer1Door1.hide()
			$Layer1Door2.hide()
			$Layer1Door3.hide()
			$Layer1Door4.hide()
		elif clearedLvl == 5:
			$Layer1Door1.hide()
			$Layer1Door2.hide()
			$Layer1Door3.hide()
			$Layer1Door4.hide()
			$Layer1Door5.hide()
			$TowerBackground/BlockBrick.hide()
			$TowerBackground/BlockBrick/CollisionShape2D.remove_and_skip()
	elif GlobalArray.layerCount == 2:
		if clearlvl == 1:
			$Layer2Door1.hide()
		elif clearedLvl == 2:
			$Layer2Door2.hide()
		elif clearedLvl == 3:
			$Layer2Door3.hide()
		elif clearedLvl == 4:
			$Layer2Door4.hide()
		elif clearedLvl == 5:
			$Layer2Door5.hide()
			$TowerBackground2/BlockBrick.hide()
			$TowerBackground2/BlockBrick/CollisionShape2D.remove_and_skip()
		
func _on_Door1_pressed():
	lvlCounter += 1
	GlobalArray.L1Door1 = true
	get_tree().change_scene("res://Game Play/Normal Level/NormalLevelQn1.tscn")
	self.queue_free()
	print("changing scene")
	print("hiding block")
	print(door1Opened)
	
func _on_Door2_pressed():
	if GlobalArray.L1Door1:
		lvlCounter += 1
		GlobalArray.L1Door2 = true
		get_tree().change_scene("res://Game Play/Normal Level/NormalLevelQn1.tscn")

func _on_Door3_pressed():
	if GlobalArray.L1Door2:
		lvlCounter += 1
		GlobalArray.L1Door3 = true
		get_tree().change_scene("res://Game Play/Normal Level/NormalLevelQn1.tscn")

func _on_Door4_pressed():
	if GlobalArray.L1Door3:
		lvlCounter += 1
		GlobalArray.L1Door4 = true
		get_tree().change_scene("res://Game Play/Normal Level/NormalLevelQn1.tscn")

func _on_Door5_pressed():
	if GlobalArray.L1Door4:
		lvlCounter += 1
		get_tree().change_scene("res://Game Play/Normal Level/NormalLevelQn1.tscn")

func _on_Lvl_cleared():
	if lvlCounter == 5:
		$TowerBackground/BlockBrick.hide()
		$TowerBackground/BlockBrick/CollisionShape2D.remove_and_skip()


