extends CanvasLayer


# Declare member variables here. Examples:
var student
var toweridx = 0
var level = 0
var	classidx = 0

var tower_name_id_dict
var classes_dict

func init(twr, lvl, cName, tnid, cd):
	toweridx = twr
	level = lvl
	classidx = cName
	tower_name_id_dict = tnid
	classes_dict = cd
	
# Called when the node enters the scene tree for the first time.
func _ready():
	print(toweridx, level, classidx)
	classOptionPopulate(classes_dict)
	towerOptionPopulate(tower_name_id_dict)
	
	$ViewLevel.select(level)
	$ViewClass.select(classidx)
	$ViewTower.select(toweridx)
	

func classOptionPopulate(c_dict):
	$ViewClass.add_item("All")
	for x in c_dict:
		$ViewClass.add_item(x)

func towerOptionPopulate(tnid):
	for x in tnid:
		$ViewTower.add_item(x)

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
