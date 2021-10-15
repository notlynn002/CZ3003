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
	#print(towerId)
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
	var topic = 'numbers' # Example topic name
	
	var challenge_questions = yield(getRandomQuestionId(topic), 'completed')
	print(challenge_questions)


# Initial creation of challenge. Takes in the challenge topic, challenger_id and challengee_id
func createChallenge(topic, challenger_id, challengee_id):
	var challenge_questions = yield(getRandomQuestionId(topic), 'completed')
	
	var challengeDetails = {
		'questionList' : challenge_questions,
		'challengerID' : challenger_id,
		'challengeeID' : challengee_id
	}
	
	var task: FirestoreTask
	var collection : FirestoreCollection = Firebase.Firestore.collection('Challenge')
	
	task = collection.add("", challengeDetails)
	var challengeID = yield(task, "task_finished")
	
	# Create Challengee Records for each of the challengees
	
	
	return challengeID.doc_name

func _on_Create_Challenge_button_up():
	# Example inputs
	var topic = 'numbers' 
	var challenger_id = 'XKwVQ9EqJ7xjEhHoPr0A'
	var challengee_id = ['P8zkYTNczGZcwLMnkbQBJsscBNp1']
	
	# Calling of function
	yield(createChallenge(topic, challenger_id, challengee_id), 'completed')


# Updates the result for a challenge. 
func updateChallengeResult(challengeId, score, time, role, userId):
	var task: FirestoreTask
	var collection : FirestoreCollection;
	# Update record for challenger
	if role == 'challenger':
		collection = Firebase.Firestore.collection('Challenge')
		task = collection.update(challengeId, {'challengerScore': score, 'challengertime' : time})
	# Update record for challengee
	else:
		# Search challengee record using challengeID - Obtain the challengee_record id.
		var query : FirestoreQuery = FirestoreQuery.new()
		query.from('Challengee_Record')
		query.where('challengeID', FirestoreQuery.OPERATOR.EQUAL, challengeId)
		query.where('challengeeID', FirestoreQuery.OPERATOR.EQUAL, userId)
	
		var query_task : FirestoreTask = Firebase.Firestore.query(query)
		var challengeeRecord = yield(query_task, 'task_finished')
		#get the recordId out
		var recordId = challengeeRecord[0].doc_name
		# Update the challengee record
		collection = Firebase.Firestore.collection('Challengee_Record')
		task = collection.update(recordId, {'challengeeScore': score, 'challengeetime' : time, 'challengeStatus': 'completed'})
		
	yield(task, 'task_finished')
	print('Record Updated!')

func _on_Update_Challenge_Result_button_up():
	var challengeId = ' KdsBS2748cPpgyxkP532'
	var challengeeId = 'P8zkYTNczGZcwLMnkbQBJsscBNp1'
	var score = 2
	var time = 1
	var role = 'challengee'
	updateChallengeResult(challengeId, score, time, role, challengeeId)


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
	
	
