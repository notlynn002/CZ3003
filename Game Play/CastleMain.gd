extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var lvlCounter = 0
var prevscene

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
	$TowerDoor1Open.hide()
	$TowerDoor2Open.hide()
	$TowerDoor3Open.hide()
	$TowerDoor4Open.hide()
	$TowerDoor5Open.hide()

func _ConfigUnit():
	#Called to change to new Sceen
	pass

func _on_Door1_pressed():
	lvlCounter += 1
	$TowerDoor1Open.show()
	#get_tree().change_scene("res://Game Play/NormalLevelQn1.tscn")
	var TheRoot = get_node("/root")  #need this as get_node will stop work once you remove your self from the Tree
	var ThisScene = get_node("/root/NormalLevelGlobal")
	#var player_vars = get_node("/root/PlayerVariables")
	NormalLevelGlobal.prevscene = ThisScene  #variable in Autoload script
	#print(ThisScene)
	#ThisScene.print_tree()
	TheRoot.remove_child(ThisScene)

	var NextScene = load("res://Game Play/NormalLevelQn1.tscn")
	NextScene = NextScene.instance()
	TheRoot.add_child(NextScene)
	
func _on_Door2_pressed():
	if door1Opened:
		lvlCounter += 1

func _on_Door3_pressed():
	if door2Opened:
		lvlCounter += 1

func _on_Door4_pressed():
	if door3Opened:
		lvlCounter += 1

func _on_Door5_pressed():
	if door4Opened:
		lvlCounter += 1

func _on_Lvl_cleared():
	if lvlCounter == 1:
		$TowerDoor1Open.show()
		door1Opened = true
	elif lvlCounter == 2:
		$TowerDoor2Open.show()
		door2Opened = true
	elif lvlCounter == 3:
		$TowerDoor3Open.show()
		door3Opened = true
	elif lvlCounter == 4:
		$TowerDoor4Open.show()
		door4Opened = true
	else:
		$TowerDoor5Open.show()
		$TowerBackground/BlockBrick.hide()
		$TowerBackground/BlockBrick/CollisionShape2D.remove_and_skip()


