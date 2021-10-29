extends CanvasLayer


# Declare member variables here. Examples:
var student
var toweridx = 0
var towerName
var level = 0
var	classidx = 0
var classID
var className
var studentOption
var teacherid = "dummyteacher1"

var allClassesID = []
var allClassesData = []

var classStatsArray
onready var statsTree = $StatsTree
var root 
var dummyCheck = 1


var tower_name_id_dict
var classes_dict	# {Numbers Tower : numbers-tower}
var tower_classes_dict = {}

var classBackend
var statsBackend

func init(twr, lvl, cName, tnid, cd, tcd):
	toweridx = twr
	level = lvl
	classidx = cName
	tower_name_id_dict = tnid
	classes_dict = cd
	tower_classes_dict = tcd
	
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

func statsUpdate():
	var currentSelection
	if studentOption == 2 and towerName and className:	
#		classStatsArray = yield(statsBackend.get_tower_stats_by_class(tower_name_id_dict[towerName], classID), "completed")
		### dummy row is added because first row gets cut from display, and im too bad to figure out another workaround
		if dummyCheck:
			currentSelection.push_front({"avg_score":"dummy", "avg_time":"dummy", "max_level":"dummy", "student_name":"dummy"})
			dummyCheck = 0
		
		if className == "All":
			currentSelection = tower_classes_dict["%s All"%towerName]
		else:
			currentSelection = tower_classes_dict["%s %s"%[towerName, className]]
			
		statsTree.clear()
		addStats(currentSelection)	


func _on_StudentOptionbutton_item_selected(index):
	studentOption = index

func _on_ViewTower_item_selected(index):
	toweridx = index

func _on_ViewLevel_item_selected(index):
	level = index

func _on_ViewClass_item_selected(index):
	classidx = index
	# reset and populate the student options button
	
func _on_BackButton_pressed():
	self.queue_free()

func addStats(data:Array):	
	for i in range(len(data)):
		var newRow = statsTree.create_item(root)
		newRow.set_text(0, str(data[i]["student_name"]))
		newRow.set_text(1, str(data[i]["max_level"]))
		newRow.set_text(2, str(data[i]["avg_score"]))
		newRow.set_text(3, str(data[i]["avg_time"]))
	
	getAvgStats(data)

func getAvgStats(data:Array):
	var avgScore = 0
	var avgTime = 0
	var avgLvl = 0
		
	for i in range(len(data)):
		avgScore += int(data[i]["avg_score"])
		avgTime += int(data[i]["avg_time"])
		avgLvl += int(data[i]["max_level"])
	
	### super bad fix for the dummydata row ###
	avgScore /= float(len(data)-1)
	avgTime /= float(len(data)-1)
	avgLvl /= float(len(data)-1)
	$AvgLabel/AvgScoreLabel.text = "%.2f"%avgScore
	$AvgLabel/AvgTimeLabel.text = "%.2f"%avgTime
	$AvgLabel/AvgLevelLabel.text = "%.2f"%avgLvl
	
	$AvgLabel.show()
