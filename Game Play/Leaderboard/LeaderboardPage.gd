extends CanvasLayer


# Declare member variables here. Examples:
var details
var tower = 'Fraction'
export (PackedScene) var Details

func init(towerName):
	tower = towerName


# Called when the node enters the scene tree for the first time.
func _ready():
	$TowerNameLabel.text = tower 
	Globals.get_node('GenericMusic').play()
	
	var results = yield(get_leaderboard(tower+'-tower'), "completed")
	
	
	# load from db
	for i in range(results.size()):
		details = str(i+1) + "          " + results[i]['name'] + "                  " + str(results[i]['highestLevel']) + "                     " + str(results[i]['totalCorrect']) + "                             " + "%d:%02d" % [floor(results[i]['timing'] / 60), int(results[i]['timing']) % 60]
#		details = str(i+1) + "          Jacob                  25                     88                             20mins"
		var deets = Details.instance()
		deets.init(details)
		$ScrollContainer/VBoxContainer.add_child(deets)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_BackButton_pressed():
	self.queue_free()


func _on_HomeButton_pressed():
	get_tree().change_scene("res://Game Play/Normal Level/NormalLevel.tscn")
	self.queue_free()


##### BACKEND FUNCTIONS #####
#output format - sorted list [{"name": String, "highestLevel", int, "totalCorrect" int, "timing" int}]
static func get_leaderboard(towerID):
	# get all the levelIDs of the boss levels in this tower
	var query : FirestoreQuery = FirestoreQuery.new()
	query.from('Level')
	query.where('towerID', FirestoreQuery.OPERATOR.EQUAL, towerID, FirestoreQuery.OPERATOR.AND)
	query.where('levelType', FirestoreQuery.OPERATOR.EQUAL,"boss")
	query.select([])
	var query_task : FirestoreTask = Firebase.Firestore.query(query)
	var result = yield(query_task, 'task_finished')
	#print(result)
	
	var attempts = []
	for i in result:
		#var q_query : FirestoreQuery = FirestoreQuery.new()
		#q_query.from('Question')
		#q_query.where('levelID', FirestoreQuery.OPERATOR.EQUAL, i.doc_name)
		#q_query.select([])
		#var qn_query : FirestoreTask = Firebase.Firestore.query(q_query)
		#var qns = yield(qn_query, 'task_finished')
		#print(i.doc_name)
		#print("____________________________________")
		#print(qns)
		for qnNo in range(1,6):
			var qn = i.doc_name +"-" + str(qnNo)
			var a_query : FirestoreQuery = FirestoreQuery.new()
			a_query.from('Question_Attempt')
			a_query.where('questionID', FirestoreQuery.OPERATOR.EQUAL, qn, FirestoreQuery.OPERATOR.AND)
			a_query.where('type', FirestoreQuery.OPERATOR.EQUAL, "first")
			
			var attempt_query : FirestoreTask = Firebase.Firestore.query(a_query)
			var qn_attempts = yield(attempt_query, 'task_finished')
			for att in qn_attempts:
				attempts.append(att.doc_fields)
			
	#print(attempts)
	
	var student_dict = {}
	# {name: , totalCorrect: , timing , highestLevel: }
	for attempt in attempts:
		var studentID = attempt.studentID
		var level = int(attempt.questionID.split("-")[1])
		
		if studentID in student_dict:
			if attempt.correct:
				student_dict[studentID]["totalCorrect"] += 1
				student_dict[studentID]["timing"] += attempt.duration
			
			student_dict[studentID]["highestLevel"] = max(student_dict[studentID].highestLevel, level)
				
		else:
			var user = yield(AuthBackend.getUser(attempt.studentID), "completed")
			
			if user != null:
				if attempt.correct:
					student_dict[studentID] = {"name": user.name, "highestLevel": level, "totalCorrect": 1, "timing": attempt.duration}
				else:
					student_dict[studentID] = {"name": user.name, "highestLevel": level, "totalCorrect": 0, "timing": 0}
	
	var rankings = student_dict.values()
	
	
	#rankings.append({"name": "earth", "highestLevel": 5, "totalCorrect": 5, "timing": 200})
	#rankings.append({"name": "moon", "highestLevel": 15, "totalCorrect": 0, "timing": 0})
	#rankings.append({"name": "sun", "highestLevel": 10, "totalCorrect": 4, "timing": 100})
	#rankings.append({"name": "star", "highestLevel": 10, "totalCorrect": 5, "timing": 200})
	
	rankings.sort_custom(LeaderboardSorter, "sort_rankings_order")
	
	return rankings
