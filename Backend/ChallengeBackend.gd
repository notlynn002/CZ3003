extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func get_towerid_by_topic(topic):
	var query : FirestoreQuery = FirestoreQuery.new()
	query.from('Tower')
	query.where('topic', FirestoreQuery.OPERATOR.EQUAL, topic)

	var query_task : FirestoreTask = Firebase.Firestore.query(query)
	var towerId = yield(query_task, 'task_finished')
	var result = towerId[0].doc_name
	return result
	
func get_levelIds_of_tower(towerId):
	var query : FirestoreQuery = FirestoreQuery.new()
	query.from('Level')
	query.where('towerID', FirestoreQuery.OPERATOR.EQUAL, towerId)

	var query_task : FirestoreTask = Firebase.Firestore.query(query)
	var result = yield(query_task, 'task_finished')
	var levelIds = []
	for level in result:
		levelIds.append(level.doc_name) 
	return levelIds


func get_qns_from_levelIds(levelIds):
	var query : FirestoreQuery = FirestoreQuery.new()
	query.from('Question')
	#Operator in not working?
	query.where('levelID', FirestoreQuery.OPERATOR.IN, levelIds)
	
	var query_task : FirestoreTask = Firebase.Firestore.query(query)
	var result = yield(query_task, 'task_finished')
	var qnIds = []
	for qn in result:
		qnIds.append(qn.doc_name)
	return qnIds

# Returns a list of 10 question Id that belongs to that topic
func getRandomQuestionId(topic):
	var towerId = yield(get_towerid_by_topic(topic), 'completed')
	var levelIds = yield(get_levelIds_of_tower(towerId), 'completed')
	var questionIds = yield(get_qns_from_levelIds(levelIds), 'completed')
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var random = []
	while(len(random)< 10):
		var number = rng.randi_range(0, len(questionIds))
		if (number in random):
			pass
		else:
			random.append(number)
	var randomed_qn_ids = [] 
	for i in random:
		randomed_qn_ids.append(questionIds[i])
	return randomed_qn_ids

# Needs to take in topic name
func _on_Create_Challenge_button_up():
	var topic = 'Four Operations' # Example topic name
	
	var challenge_questions = yield(getRandomQuestionId(topic), 'completed')
	print(challenge_questions)
