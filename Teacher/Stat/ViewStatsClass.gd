extends CanvasLayer

### TO DO: STATS PER LEVEL ###
# Declare member variables here. Examples:
var toweridx = 0
var towerName
var level = 0
var	classidx = 0
var classID
var className
var viewByOption
var teacherid = "dummyteacher1"

var allClassesID = []
# allClassesID: [Class-A, Class-C, Class-D, dummyClass]
var allClassesData = []
var classStatsArray

onready var statsTree = $StatsTree
var root 

var quiz_name_id_dict = {}
# qnid: { className: {quiz name: quiz id}}
var tower_name_id_dict
# tnid: {Fraction Tower:fraction-tower, Numbers Tower:numbers-tower, Quiz Tower:quiz-tower, Ratio Tower:ratio-tower}
var classes_dict 
# classes_dict: {Class A:Class-A, Class C:Class-C, Class D:Class-D, dummyClass:dummyClass}

var tower_classes_dict = {}
# {Numbers Tower All:[
# {avg_score:0, avg_time:0, max_level:0, student_name:dumb1}, 
# {avg_score:0, avg_time:0, max_level:0, student_name:dumb2}, 
# {avg_score:0, avg_time:0, max_level:0, student_name:B}, 
# {avg_score:0, avg_time:0, max_level:0, student_name:Zixuan}, 
# {avg_score:0, avg_time:0, max_level:4, student_name:jiarui}, 
# {avg_score:3, avg_time:1778, max_level:5, student_name:parth}, 
# {avg_score:0, avg_time:0, max_level:0, student_name:tired}, 
# {avg_score:0, avg_time:0, max_level:0, student_name:A}, 
# {avg_score:3, avg_time:1792, max_level:5, student_name:Glenda Hong}, 
# {avg_score:0, avg_time:0, max_level:0, student_name:sleepy}, 
# {avg_score:0, avg_time:0, max_level:4, student_name:aabbcc}, 
# {avg_score:0, avg_time:0, max_level:0, student_name:mushroom}], 
#

# Numbers Tower Class C:[], Numbers Tower Class D:[...], Numbers Tower dummyClass:[...]}

var classBackend
var statsBackend = preload("res://Backend/StatsBackend.tscn").instance()


#var dummyData = [{"avg_score":"0", "avg_time":"0", "max_level":"1", "student_name":"studentUpdated"}, 
#{"avg_score":"0", "avg_time":"0", "max_level":"2", "student_name":"lin sw"}, 
#{"avg_score":"2", "avg_time":"416.5", "max_level":"10", "student_name":"TestStudent007"}]
#
#var dummyDataB = [{"avg_score":"3", "avg_time":"2", "max_level":"3", "student_name":"stu001"}, 
#{"avg_score":"4", "avg_time":"11", "max_level":"7", "student_name":"stu002"}, 
#{"avg_score":"5", "avg_time":"16.5", "max_level":"12", "student_name":"stu003"}]
			
func init(tid, cbe):
	teacherid = tid
	classBackend = cbe
	
# Called when the node enters the scene tree for the first time.
func _ready():
	statsTreeInit()	
	
	$AvgLabel.hide()
	ClassBackend.get_classes(teacherid)
	# print(yield(classBackend.get_classes(teacherid), "completed"))
	# var get_classes_list = yield(classBackend.get_classes(teacherid), "completed")
	
	### query these before reaching the stats page? load time is slow ###
	
	classes_dict = yield(statsBackend.get_class_ids_and_names(teacherid), "completed")
	classOptionPopulate(classes_dict)
	quizData()

	tower_name_id_dict = yield(statsBackend.get_tower_ids_and_names(), "completed")
	towerOptionPopulate(tower_name_id_dict)
#
#	### experimental preload ### tower_name_id_dict instead of hardcode
#	### below needs db to be populated 
#	var temp = OS.get_unix_time()
#	for x in tower_name_id_dict:
#		tower_classes_dict["%s All"%x] = yield(statsBackend.get_tower_stats_by_class(tower_name_id_dict[x], allClassesID), "completed")	
#		addDummyRow(tower_classes_dict["%s All"%x])
#		addDummyRow(tower_classes_dict["%s All"%x])
#		for y in classes_dict:
#			tower_classes_dict["%s %s"%[x, y]] = yield(statsBackend.get_tower_stats_by_class(tower_name_id_dict[x], [classes_dict[y]]), "completed")
#			addDummyRow(tower_classes_dict["%s %s"%[x, y]])
#			addDummyRow(tower_classes_dict["%s %s"%[x, y]])
#	print("time taken: %ds" % (OS.get_unix_time()-temp))
	$Loading.hide()
	
#	classStatsArray = yield(statsBackend.get_tower_stats_by_class(tower_name_id_dict[towerName], classID), "completed")
#	# [{qn_attempts: [{qn_content:John had 10 apples. He ate one. How many oranges does he have left?, result:-}], student_name:dumb1, time:-},
#	var stud_name_id_dict = yield(statsBackend.get_student_ids_and_names([className]), "completed")
#	print(stud_name_id_dict)

func statsTreeInit():
	root = statsTree.create_item()
	
func classOptionPopulate(c_dict):
	$ViewClass.add_item("All")
	for x in c_dict:
		$ViewClass.add_item(x)
		allClassesID.append(c_dict[x])

func towerOptionPopulate(tnid):
	for x in tnid:
		$ViewTower.add_item(x)

func levelOptionPopulate():
	$ViewLevel.clear()
	print(quiz_name_id_dict)
	if towerName == "Quiz Tower" and className:
		print(quiz_name_id_dict[className])
		for x in quiz_name_id_dict[className]:
			print(x)
			$ViewLevel.add_item(x)
	else: 
		for x in range(1, 26):
			$ViewLevel.add_item("Level %d"%x)
		
	

func statsUpdate():
	var currentSelection
	### Array of student stats ###
	
	if viewByOption == 1 and towerName and className:	
#		classStatsArray = yield(statsBackend.get_tower_stats_by_class(tower_name_id_dict[towerName], classID), "completed")
		### dummy row is added because first row gets cut from display, and im too bad to figure out another workaround
		if className == "All":
			currentSelection = tower_classes_dict["%s All"%towerName]
		else:
			currentSelection = tower_classes_dict["%s %s"%[towerName, className]]
		
		statsTree.clear()
		## 2 dummy rows used. FIX THIS if I figure out a better display output!!!
		if len(currentSelection) > 2:
			addStats(currentSelection)	
		else:
			$AvgLabel.hide()
		

func quizData():
	for x in classes_dict:
		quiz_name_id_dict["%s"%x] = yield(StatsBackend._get_quiz_ids_and_names([classes_dict[x]]), "completed")
	print(quiz_name_id_dict)
		
func addDummyRow(currentSelection):
	currentSelection.push_front({"avg_score":"dummy", "avg_time":"dummy", "max_level":"dummy", "student_name":"dummy"})
	
func _on_ViewByOptionbutton_item_selected(index):
	viewByOption = index
	
	if index == 2:
		var root = get_tree().root
		var createViewStatsStudentPage = preload("res://Teacher/Stat/ViewStatsStudent.tscn").instance()
		createViewStatsStudentPage.init(toweridx, level, classidx, tower_name_id_dict, classes_dict, tower_classes_dict)
		root.add_child(createViewStatsStudentPage)
	else:
		statsUpdate()

func _on_ViewTower_item_selected(index):
	toweridx = index
	towerName = $ViewTower.get_item_text(index)
	levelOptionPopulate()
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
		###ignore the class - and all options ###
		for x in range(2, $ViewClass.get_item_count()):	
			dummyArr.append($ViewClass.get_item_text(x))
		className = "All"
		classID = dummyArr
	else:
		classidx = index
		className = $ViewClass.get_item_text(index)
		classID = [classes_dict[className]]
		
	levelOptionPopulate() ### UNTESTED ###
	statsUpdate()

func _on_BackButton_pressed():
	self.queue_free()

### data processing ###
### [{ avg_score, avg_time, max_level, student_name }] ###

func addStats(data:Array):	
	
	for i in range(1, len(data)):
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
	
	
	
### [{avg_score:0, avg_time:0, max_level:1, student_name:studentUpdated},
###	 {avg_score:0, avg_time:0, max_level:2, student_name:lin sw},
###	 {avg_score:2, avg_time:416.5, max_level:10, student_name:TestStudent007}]

