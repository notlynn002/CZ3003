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
	$TowerBackground/BlockBrick.hide()
	$TowerBackground/BlockBrick/CollisionShape2D.remove_and_skip()
	
func init(clearedLvl):
	clearlvl = clearedLvl
	if clearlvl == 1:
		$Door1.hide()
		$TowerBackground/BlockBrick.hide()
		$TowerBackground/BlockBrick/CollisionShape2D.remove_and_skip()
	elif clearedLvl == 2:
		$Door2.hide()
	elif clearedLvl == 3:
		$Door3.hide()
	elif clearedLvl == 4:
		$Door4.hide()
	elif clearedLvl == 5:
		$Door5.hide()
		
func _on_Door1_pressed():
	lvlCounter += 1
	door1Opened = true
	get_tree().change_scene("res://Game Play/Normal Level/NormalLevelQn1.tscn")
	print("changing scene")
	print("hiding block")
	
func _on_Door2_pressed():
	if door1Opened:
		lvlCounter += 1
		door2Opened = true
		get_tree().change_scene("res://Game Play/Normal Level/NormalLevelQn1.tscn")

func _on_Door3_pressed():
	if door2Opened:
		lvlCounter += 1
		door2Opened = true
		get_tree().change_scene("res://Game Play/Normal Level/NormalLevelQn1.tscn")

func _on_Door4_pressed():
	if door3Opened:
		lvlCounter += 1
		door3Opened = true
		get_tree().change_scene("res://Game Play/Normal Level/NormalLevelQn1.tscn")

func _on_Door5_pressed():
	if door4Opened:
		lvlCounter += 1
		#get_tree().change_scene("res://Game Play/BossLevel.tscn")

func _on_Lvl_cleared():
	if lvlCounter == 1:
		$TowerBackground/BlockBrick.hide()
		$TowerBackground/BlockBrick/CollisionShape2D.remove_and_skip()


