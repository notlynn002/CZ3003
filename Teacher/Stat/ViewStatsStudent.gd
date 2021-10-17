extends CanvasLayer


# Declare member variables here. Examples:
var student
var toweridx = 0
var level = 0
var	classidx = 0

func init(twr, lvl, cName):
	toweridx = twr
	level = lvl
	classidx = cName
	
# Called when the node enters the scene tree for the first time.
func _ready():
	print(toweridx, level, classidx)
	$ViewLevel.select(level)
	$ViewClass.select(classidx)
	$ViewTower.select(toweridx)
	pass

func _on_StudentOptionbutton_item_selected(index):
	student = index

func _on_ViewTower_item_selected(index):
	toweridx = index

func _on_ViewLevel_item_selected(index):
	level = index

func _on_ViewClass_item_selected(index):
	classidx = index
	# reset and populate the student options button
	
func _on_BackButton_pressed():
	self.queue_free()
