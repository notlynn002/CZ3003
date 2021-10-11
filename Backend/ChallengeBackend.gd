extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# ------------ Get Random questions and Create Challenge --------------------

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
		var number = rng.randi_range(0, len(questionIds)-1)
		if (number in random):
			pass
		else:
			random.append(number)
	var randomed_qn_ids = [] 
	for i in random:
		randomed_qn_ids.append(questionIds[i])
	return randomed_qn_ids

#Pass in topic name
func _on_Get_10_Random_Qns_button_up():
	var topic = 'Four Operations' # Example topic name
	
	var challenge_questions = yield(getRandomQuestionId(topic), 'completed')
	print(challenge_questions)


func createChallenge(challengeQns, challenger_time, challenger_score, challenger_id, challengee_id):
	var challengeDetails = {
		'questionList' : challengeQns,
		'challengerTime' : challenger_time,
		'challengerScore' : challenger_score,
		'challengerID' : challenger_id,
		'challengeeID' : challengee_id
	}
	
	var task: FirestoreTask
	var collection : FirestoreCollection = Firebase.Firestore.collection('Challenge')
	
	task = collection.add("", challengeDetails)
	yield(task, "task_finished")

#
func _on_Create_Challenge_button_up():
	# Example inputs
	var topic = 'Four Operations' # Example topic name
	var challenge_questions = yield(getRandomQuestionId(topic), 'completed') # Example questions
	var challenger_time = 5
	var challenger_score = 5
	var challenger_id = 'XKwVQ9EqJ7xjEhHoPr0A'
	var challengee_id = ['P8zkYTNczGZcwLMnkbQBJsscBNp1']
	
	# Calling of function
	yield(createChallenge(challenge_questions, challenger_time, challenger_score, challenger_id, challengee_id), 'completed')


#------------ Reject Challenge----------------
func reject_challenge(challengeId, challengeeid):
	var collection : FirestoreCollection = Firebase.Firestore.collection('Challenge')
	collection.get(challengeId)	
	var challenge :FirestoreDocument = yield(collection, "get_document")
	
	# Get all challengeeIds for challenge and remove the denoted challengeeid
	var challengeeId = challenge.doc_fields.challengeeID
	
	var updated_challengeeId = []
	for id in challengeeId:
		if id != challengeeid:
			updated_challengeeId.append(id)
	
	#Update to firestore
	var task: FirestoreTask
	task = collection.update(challengeId, {'challengeeID': updated_challengeeId})
	yield(task, "task_finished")
	

func _on_Reject_Challenge_button_up():
	var challengeId = 'NqHewZ5mStJaco9dECqT'
	var challengeeId = 'P8zkYTNczGZcwLMnkbQBJsscBNp1'
	reject_challenge(challengeId, challengeeId)
