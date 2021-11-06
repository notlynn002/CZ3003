extends CanvasLayer

# Declare member variables here. Examples:
var toweridx = 0
var towerName
var level = 0
var levelName
var	classidx = 0
var classID
var className
var viewByOption
var teacherid = "dummyteacher1"

var allClassesID = []
# allClassesID: [Class-A, Class-C, Class-D, dummyClass]
var allClassesData = []
var classStatsArray

var level_name_id_dict = {}
# lnid: {towerName : {}, towerName: {}}
var allLevelStats = {}

onready var statsTree = $StatsTree
var root 

var quiz_classname_id_dict = {}
# qnid: { className: {quiz name: quiz id}}\
var allQuizID = {}
# { className: [ quiz-id, ...] }
var allQuizName = {}
var allQuizData = {}

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
	
	$AvgLabel.visible = false
	$StuStatsLabel.visible = false
	$ClassStatsLabel.visible = false
	ClassBackend.get_classes(teacherid)
	# print(yield(classBackend.get_classes(teacherid), "completed"))
	# var get_classes_list = yield(classBackend.get_classes(teacherid), "completed")
	
	classes_dict = yield(statsBackend.get_class_ids_and_names(teacherid), "completed")
	classOptionPopulate(classes_dict)

	tower_name_id_dict = yield(statsBackend.get_tower_ids_and_names(), "completed")
	towerOptionPopulate(tower_name_id_dict)
	
	for x in tower_name_id_dict:
		if tower_name_id_dict[x] != "quiz-tower":
			level_name_id_dict["%s"%x] = (yield(statsBackend.get_level_ids_and_names(tower_name_id_dict[x]), "completed"))

	for x in classes_dict:
		for y in level_name_id_dict:
			for z in range(level_name_id_dict[y].size()):
				allLevelStats["%s %s"%[x, level_name_id_dict[y].values()[z]]] = yield(statsBackend.get_level_stats_by_class(level_name_id_dict[y].values()[z], [classes_dict[x]]), "completed")
		
	var temp = OS.get_unix_time()
	print(temp)
	
	for x in classes_dict:	#x == className
		quiz_classname_id_dict["%s"%x] = yield(StatsBackend._get_quiz_ids_and_names([classes_dict[x]]), "completed")
		allQuizID["%s"%x] = []
		for y in quiz_classname_id_dict[x]:	#y == quizName
			allQuizID["%s"%x].append(quiz_classname_id_dict[x][y])
			allQuizData["%s %s"%[x, y]] = (yield(StatsBackend.get_quiz_stats_by_class(quiz_classname_id_dict[x][y] , [classes_dict[x]]), "completed"))

	print("quizhell done!")
	for x in tower_name_id_dict:
		tower_classes_dict["%s All"%x] = yield(statsBackend.get_tower_stats_by_class(tower_name_id_dict[x], allClassesID), "completed")	
		addDummyRow(tower_classes_dict["%s All"%x])
		for y in classes_dict:
			tower_classes_dict["%s %s"%[x, y]] = yield(statsBackend.get_tower_stats_by_class(tower_name_id_dict[x], [classes_dict[y]]), "completed")
			addDummyRow(tower_classes_dict["%s %s"%[x, y]])

	print("time taken: %ds" % (OS.get_unix_time()-temp))
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
	if towerName == "Quiz Tower" and className:
		print(len(allQuizID[className]))
		if len(allQuizID[className]) == 0:
			$ViewLevel.add_item("No quizzes")
			$StatsTree.hide()
		else:
			for x in quiz_classname_id_dict[className]:
				$ViewLevel.add_item(x)
			$StatsTree.show()
	elif towerName and className: 
		for x in level_name_id_dict[towerName]:
			$ViewLevel.add_item(x)
		
#		for x in range(1, 26):
#			$ViewLevel.add_item("Level %d"%x)

func statsUpdate():
	var currentSelection
	### Array of student stats ###
	
	if viewByOption == 1 and towerName and className:	
#		classStatsArray = yield(statsBackend.get_tower_stats_by_class(tower_name_id_dict[towerName], classID), "completed")
		### dummy row is added because first row gets cut from display, and im too bad to figure out another workaround
		if towerName == "Quiz Tower" and className:
			quizSelected()
			return
		
		if towerName != "Quiz Tower" and className == "All":
			currentSelection = tower_classes_dict["%s All"%towerName]
		elif towerName != "Quiz Tower" and className:
			currentSelection = tower_classes_dict["%s %s"%[towerName, className]]
		statsTree.clear()
		## 2 dummy rows used. FIX THIS if I figure out a better display output!!!
		if len(currentSelection) > 1:
			addStats(currentSelection)	
		else:
			$AvgLabel.hide()
	

func addDummyRow(currentSelection):
	currentSelection.push_front({"avg_score":"dummy", "avg_time":"dummy", "max_level":"dummy", "student_name":"dummy"})
	
func _on_ViewByOptionbutton_item_selected(index):
	viewByOption = index
	
	if index == 2:
		pass
		#DO STUDENT FUNCTIONS HERE
	else:
		statsUpdate()

func _on_ViewTower_item_selected(index):
	toweridx = index
	towerName = $ViewTower.get_item_text(index)
	levelOptionPopulate()
	statsUpdate()
	#print(yield(statsBackend._get_boss_level_ids_and_names(tower_name_id_dict[towerName]), "completed"))
	
func _on_ViewLevel_pressed():
	print(level_name_id_dict[towerName][levelName])
	var lvl = allLevelStats["%s %s"%[className, level_name_id_dict[towerName][levelName]]]
	$StatsTree.clear()
	addStatsLevel(lvl)
# [  [ { qn_attempts: [{qn_content: , result: }, {qn_content: , result: } ], student_name: , time: } ]
# array array(per student) dict( qn_attempts(dict) : array( dict(content, result)), student_name, time  )



func quizMarker(data:Dictionary):
	### No actual way to get full question count for quiz for now 
	var results = [0 , data["qn_attempts"].size()]
	for x in range(data["qn_attempts"].size()):
		if data["qn_attempts"][x]["result"] == "correct":
			results[0] += 1
		elif data["qn_attempts"][x]["result"] == "-":
			results[1] -= 1
	return results

func quizSelected():
	var quizStats = []
	var dummyRow = {"marks":["dummy", "dummy"], "student_name":"dummy", "time":"dummy"}
	quizStats.append(dummyRow)
	for attempt in allQuizData["%s %s"%[className, levelName]]:
		attempt["marks"] = quizMarker(attempt)
		quizStats.append(attempt)
		
	$StatsTree.clear()
	print(len(quizStats))
	if len(quizStats) > 1:
		addStatsQuiz(quizStats)

func _on_ViewLevel_item_selected(index):
	level = index
	levelName = $ViewLevel.get_item_text(index)
	statsUpdate()
		
	
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
		
	levelOptionPopulate()
	statsUpdate()

func _on_BackButton_pressed():
	self.queue_free()

### data processing ###
### [{ avg_score, avg_time, max_level, student_name }] ###

func addStats(data:Array):	
	if $ClassStatsLabel.visible == true:	
		$ClassStatsLabel.hide()
	$StuStatsLabel.show()
	for i in range(len(data)):
		var newRow = statsTree.create_item(root)
		newRow.set_text(0, str(data[i]["student_name"]))
		newRow.set_text(1, str(data[i]["max_level"]))
		newRow.set_text(2, str(data[i]["avg_score"]))
		newRow.set_text(3, str(data[i]["avg_time"]))

	getAvgStats(data)

func addStatsQuiz(data:Array):
	for i in range(len(data)):
		var newRow = statsTree.create_item(root)
		newRow.set_text(0, str(data[i]["student_name"]))
		newRow.set_text(1, str(data[i]["marks"][1]))
		newRow.set_text(2, str(data[i]["marks"][0]))
		newRow.set_text(3, str(data[i]["time"]))

func addStatsLevel(data:Array):
	if $StuStatsLabel.visible == true:
		$StuStatsLabel.hide()
	$ClassStatsLabel.show()
	for i in range(len(data)):
		var newRow = statsTree.create_item(root)
		newRow.set_text(0, str(data[i]["qn_no"]))
		newRow.set_text(1, str(data[i]["attempt_percent"]))
		newRow.set_text(2, str(data[i]["correct_percent"]))
		newRow.set_text(3, str(data[i]["avg_time"]))
		
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

