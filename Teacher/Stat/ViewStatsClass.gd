extends CanvasLayer

### TO DO: AVG STATS FOR THE CLASS ###
# Declare member variables here. Examples:
var toweridx = 0
var towerName
var level = 0
var	classidx = 0
var classID
var className
var viewByOption
var teacherid = "dummyteacher1"

var classStatsArray
onready var statsTree = $StatsTree
var root 

var tower_name_id_dict
var classes_dict

var statsBackend = preload("res://Backend/StatsBackend.tscn").instance()
var classBackend = preload("res://Backend/ClassBackend.tscn").instance()
# remove classbackend preload after testing

func init(tid, cbe):
	teacherid = tid
	classBackend = cbe
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	# print(yield(classBackend.get_classes(teacherid), "completed"))
	# var get_classes_list = yield(classBackend.get_classes(teacherid), "completed")
	
	### query these before reaching the stats page? load time is slow ###
	
	classes_dict = yield(statsBackend.get_class_ids_and_names(teacherid), "completed")
	print(classes_dict)
	classOptionPopulate(classes_dict)
	
	tower_name_id_dict = yield(statsBackend.get_tower_ids_and_names(), "completed")
	print(tower_name_id_dict)
	towerOptionPopulate(tower_name_id_dict)
	

	
#	var stud_name_id_dict = yield(statsBackend.get_student_ids_and_names([className]), "completed")
#	print(stud_name_id_dict)
	
	
func classOptionPopulate(c_dict):
	$ViewClass.add_item("All")
	for x in c_dict:
		$ViewClass.add_item(x)

func towerOptionPopulate(tnid):
	for x in tnid:
		$ViewTower.add_item(x)
		
func statsUpdate():
		if viewByOption == 1 and towerName and className:	
			classStatsArray = yield(statsBackend.get_tower_stats_by_class(tower_name_id_dict[towerName], classID), "completed")
			print(classStatsArray)
			addStats(classStatsArray)
	
func _on_ViewByOptionbutton_item_selected(index):
	viewByOption = index
	
	if index == 2:
		var root = get_tree().root
		var createViewStatsStudentPage = preload("res://Teacher/Stat/ViewStatsStudent.tscn").instance()
		createViewStatsStudentPage.init(toweridx, level, classidx)
		root.add_child(createViewStatsStudentPage)
	else:
		statsUpdate()

func _on_ViewTower_item_selected(index):
	toweridx = index
	towerName = $ViewTower.get_item_text(index)
	statsUpdate()
	#print(yield(statsBackend._get_boss_level_ids_and_names(tower_name_id_dict[towerName]), "completed"))
	
func _on_ViewLevel_pressed():
	pass

func _on_ViewLevel_item_selected(index):
	level = index

func _on_ViewClass_item_selected(index):
	
	### all function not fully tested, db doesnt have more than one class with attempts ###
	
	if index == 1:
		var dummyArr = []
		for x in range(2, $ViewClass.get_item_count()):	###ignore the class - and all options ###
			dummyArr.append($ViewClass.get_item_text(x))
		className = "All"
		classID = dummyArr
	else:
		classidx = index
		className = $ViewClass.get_item_text(index)
		classID = [classes_dict[className]]
		
	statsUpdate()

func _on_BackButton_pressed():
	self.queue_free()

### data processing ###
### [{ avg_score, avg_time, max_level, student_name }] ###

func addStats(data:Array):
	root = statsTree.create_item()
	
	var headers = statsTree.create_item(root)
	headers.set_text(0, "Student")
	headers.set_text(1, "Max level")
	headers.set_text(2, "Avg. Score")
	headers.set_text(3, "Avg. Time Taken")
	
	for i in range(len(data)):
		var newRow = statsTree.create_item(root)
		newRow.set_text(0, data[i]["student_name"])
		newRow.set_text(1, str(data[i]["max_level"]))
		newRow.set_text(2, str(data[i]["avg_score"]))
		newRow.set_text(3, str(data[i]["avg_time"]))

	
