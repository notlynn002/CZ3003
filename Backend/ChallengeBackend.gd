extends CanvasLayer

class_name ChallengeBackend

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

static func getChallengeByID(challengeID):
	""" Get challenge information using a challenge ID.
	
	Args:
		challengeID (String): Challenge ID.
		
	Returns:
		Dictionary: The challenge information. The challenge dictionary will contain the following fields:
			"challengeeID" (Array): The user IDs of the challengees.
			"challengerID" (String): The user ID of the challenger.
			"questionList" (Array[Dictionary]): The challenge questions represented as dictionaries.
				Each question dictionary will contain the following fields:
					"questionBody" (String): Question content.
					"questionID" (String): Question ID.
					"questionOptions" (Array[String]): The question options as strings.
					"questionSoln" (String): Question solution.
			 
	"""
	var collection : FirestoreCollection = Firebase.Firestore.collection('Challenge')
	collection.get(challengeID)	
	var challenge : FirestoreDocument = yield(collection, "get_document")
	var result = challenge.doc_fields
	return result
	
func _on_Get_Challenge_by_Id_button_up():
	var challengeId = '88LxsRnLsf77NDe6Cx3U'
	var output = yield(getChallengeByID(challengeId), "completed")
	print(output)


# ------------ Get Random questions and Create Challenge --------------------

static func get_towerid_by_topic(topic):
	"""Get the tower ID of a game tower using the tower topic.
	
	Args:
		topic (String): Tower topic.
		
	Returns:
		String: The tower ID.
	
	"""
	var query : FirestoreQuery = FirestoreQuery.new()
	query.from('Tower')
	query.where('topic', FirestoreQuery.OPERATOR.EQUAL, topic)

	var query_task : FirestoreTask = Firebase.Firestore.query(query)
	var towerId = yield(query_task, 'task_finished')
	#print(towerId)
	var result = towerId[0].doc_name
	return result
	
static func get_levelIds_of_tower(towerId):
	"""Get the level IDs of level in a game tower.
	
	Args:
		towerId (String): Tower ID of the game tower.
		
	Returns:
		Array[String]: The level IDs.
	"""
	var query : FirestoreQuery = FirestoreQuery.new()
	query.from('Level')
	query.where('towerID', FirestoreQuery.OPERATOR.EQUAL, towerId)

	var query_task : FirestoreTask = Firebase.Firestore.query(query)
	var result = yield(query_task, 'task_finished')
	var levelIds = []
	for level in result:
		levelIds.append(level.doc_name) 
	return levelIds


static func get_qns_from_levelIds(levelIds):
	"""Get information of questions in a few game levels.
	
	Args:
		levelIds (Array[String]): Level IDs of the levels.
		
	Returns:
		Array[Dictionary]: The questions as dictionaries. Each question dictionary contains the following fields:
			"levelID" (String): Level ID.
			"questionBody" (String): Question content.
			"questionExplanation" (String): Question explanation.
			"questionNo" (String): Question number.
			"questionOptions" (Array[String]): The question options as strings.
			"questionSoln" (String): Question solution.
	"""
	var query : FirestoreQuery = FirestoreQuery.new()
	query.from('Question')
	query.where('levelID', FirestoreQuery.OPERATOR.IN, levelIds)
	
	var query_task : FirestoreTask = Firebase.Firestore.query(query)
	var result = yield(query_task, 'task_finished')
	var questions = []
	for question in result:
		var q = {
			'questionBody' : question.doc_fields.questionBody,
			'questionOptions' : question.doc_fields.questionOptions,
			'questionSoln' : question.doc_fields.questionSoln,
			'questionID' : question.doc_name
		}
		questions.append(q)
	#print(questions)
	return questions

# Returns a list of 10 question Id that belongs to that topic
static func getRandomQuestions(topic):
	"""Get 10 random questions from a game tower.
	
	Args:
		topic (String): Tower topic.
		
	Returns:
		Array[Dictionary]: The 10 questions as dictionaries. Each question dictionary contains the following fields:
			"levelID" (String): Level ID.
			"questionBody" (String): Question content.
			"questionExplanation" (String): Question explanation.
			"questionNo" (String): Question number.
			"questionOptions" (Array[String]): The question options as strings.
			"questionSoln" (String): Question solution.
	"""
	var towerId = yield(get_towerid_by_topic(topic), 'completed')
	var levelIds = yield(get_levelIds_of_tower(towerId), 'completed')
	var questions = yield(get_qns_from_levelIds(levelIds), 'completed')
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var random = []
	while(len(random)< 10):
		var number = rng.randi_range(0, len(questions)-1)
		if (number in random):
			pass
		else:
			random.append(number)
	var randomed_qns = [] 
	for i in random:
		randomed_qns.append(questions[i])
	return randomed_qns

#Pass in topic name
func _on_Get_10_Random_Qns_button_up():
	var topic = 'numbers' # Example topic name
	
	var challenge_questions = yield(getRandomQuestions(topic), 'completed')
	print(challenge_questions)


# Initial creation of challenge. Takes in the challenge topic, challenger_id and challengee_id
static func createChallenge(topic, challenger_id, challengee_id):
	"""Create a new challenge.
	
	The challenge data will be written into the database. 
	
	Args:
		topic (String): Tower topic.
		challenger_id (String): User ID of the challenger.
		challengee_id (Array[String]): User IDs of the challengees.
		
	"""
	var challenge_questions = yield(getRandomQuestions(topic), 'completed')
	
	var challengeDetails = {
		'questionList' : challenge_questions,
		'challengerID' : challenger_id,
		'challengeeID' : challengee_id
	}
	
	var task: FirestoreTask
	var collection : FirestoreCollection = Firebase.Firestore.collection('Challenge')
	
	task = collection.add("", challengeDetails)
	var challengeID = yield(task, "task_finished")
	challengeID = challengeID.doc_name
	
	var challengee_collection : FirestoreCollection = Firebase.Firestore.collection('Challengee_Record')
	
	var challengee_record ={
			"challengeID" : challengeID, 
			"challengeStatus": 'sent', 
		}
	# Create Challengee Records for each of the challengees
	for challengee in challengee_id:
		challengee_record["challengeeID"] = challengee
		
		var add_challengee_record : FirestoreTask = challengee_collection.add("", challengee_record)
		yield(add_challengee_record, "task_finished")
	
	return challengeID

func _on_Create_Challenge_button_up():
	# Example inputs
	var topic = 'numbers' 
	var challenger_id = '6IJC8LDr4KeEHHzyZi9iypVpnga2'
	var challengee_id = ['XKwVQ9EqJ7xjEhHoPr0A']
	
	# Calling of function
	var challengeId = yield(createChallenge(topic, challenger_id, challengee_id), 'completed')
	print(challengeId)


# Updates the result for a challenge. 
static func updateChallengeResult(challengeId, score, time, userId):
	"""Updates challenge data in the database to reflect a challenge participant's challenge attempt.
	
	Args:
		challengeId (String): Challenge ID.
		score (int): Participant's attempt score.
		time (int): The time the participant took to completed the challenge as total seconds.
		userId (String): User ID of the participant.
		
	"""
	var challenge = yield(getChallengeByID(challengeId), 'completed')
	
	var task: FirestoreTask
	var collection : FirestoreCollection;
	# Update record for challenger
	if userId == challenge['challengerID']:
		collection = Firebase.Firestore.collection('Challenge')
		task = collection.update(challengeId, {'challengerScore': score, 'challengerTime' : time})
	# Update record for challengee
	else:
		# Search challengee record using challengeID - Obtain the challengee_record id.
		var query : FirestoreQuery = FirestoreQuery.new()
		query.from('Challengee_Record')
		query.where('challengeID', FirestoreQuery.OPERATOR.EQUAL, challengeId)
		#query.where('challengeeID', FirestoreQuery.OPERATOR.EQUAL, userId)
	
		var query_task : FirestoreTask = Firebase.Firestore.query(query)
		var challengeeRecord = yield(query_task, 'task_finished')
		#get the recordId out
		var recordId = challengeeRecord[0].doc_name
		# Update the challengee record
		collection = Firebase.Firestore.collection('Challengee_Record')
		task = collection.update(recordId, {'challengeeScore': score, 'challengeeTime' : time, 'challengeStatus': 'completed'})
		
	yield(task, 'task_finished')
	print('Record Updated!')

func _on_Update_Challenge_Result_button_up():
	var challengeId = 'b4JIPytaqNSsDVukEUEi'
	var challengerId = '6IJC8LDr4KeEHHzyZi9iypVpnga2'
	var challengeeId = 'XKwVQ9EqJ7xjEhHoPr0A'
	var score = 6
	var time = 150
	
	updateChallengeResult(challengeId, score, time, challengerId)


#------------ Reject Challenge----------------
static func rejectChallenge(challengeId, challengeeID):
	"""Allows a challengee to reject a challenge.
	
	The challenge data in the database will be updated to reflect the rejection.
	A notification will also be sent to the challenger about the challengee declining the challenge.
	
	Args:
		challengeId (String): Challenge ID.
		challengee (String): User ID of challengee.	
	
	"""
	var collection : FirestoreCollection = Firebase.Firestore.collection('Challenge')
	collection.get(challengeId)	
	var challenge :FirestoreDocument = yield(collection, "get_document")
	
	# Get all challengeeIds for challenge and remove the denoted challengeeid
	var challengeeIds = challenge.doc_fields.challengeeID
	
	var updated_challengeeId = []
	for id in challengeeIds:
		if id != challengeeID:
			updated_challengeeId.append(id)
	
	#Update to firestore
	var task: FirestoreTask
	task = collection.update(challengeId, {'challengeeID': updated_challengeeId})
	yield(task, "task_finished")
	
	#Update challengee record into declined
	var query : FirestoreQuery = FirestoreQuery.new()
	query.from('Challengee_Record')
	query.where('challengeID', FirestoreQuery.OPERATOR.EQUAL, challengeId, FirestoreQuery.OPERATOR.AND)
	query.where('challengeeID', FirestoreQuery.OPERATOR.EQUAL, challengeeID)
	var query_task : FirestoreTask = Firebase.Firestore.query(query)
	var challengeeRecord = yield(query_task, 'task_finished')
	challengeeRecord = challengeeRecord[0].doc_name
	
	var challengee_collection : FirestoreCollection = Firebase.Firestore.collection('Challengee_Record')
	var update_task : FirestoreTask =challengee_collection.update(challengeeRecord, {"challengeStatus" : "declined"})
	yield(update_task, 'task_finished')

func _on_Reject_Challenge_button_up():
	var challengeId = 'KdsBS2748cPpgyxkP532'
	var challengeeId = 'P8zkYTNczGZcwLMnkbQBJsscBNp1'
	rejectChallenge(challengeId, challengeeId)
	
	
#------------ Get Challenge Result ----------------
	
static func getChallengeResult(challengeID, challengeeID):
	"""Get the result of a completed challenge.
	
	Args:
		challengeID (String): Challenge ID.
		challengeeID (String): User ID of the challengee.
		
	Returns:
		Dictionary: The challenge result. The result dictionary will contain the following fields:
			'winnerName' (String): The name of the winner.
			'loserName' (String): The name of the loser.
			'winnerId' (String): The user ID of the winner.
			'loserId' (String): The user ID of the loser.
			'winnerTime' (int): The time the winner took to complete the challenge.
			'loserTime' (int): The time the loser took to complete the challenge
			'winnerScore' (int): The winner's score.
			'loserScore' (int): The loser's score.
			
	"""
	var user_collection : FirestoreCollection = Firebase.Firestore.collection('User')
	
	# Get challenger data
	var challenger_collection : FirestoreCollection = Firebase.Firestore.collection('Challenge')
	challenger_collection.get(challengeID)
	var challengerRecord = yield(challenger_collection, 'get_document')
	challengerRecord = challengerRecord.doc_fields
	
	#print(challengerRecord)
	
	user_collection.get(challengerRecord['challengerID'])
	var challengerDetails = yield(user_collection, 'get_document')
	challengerDetails = challengerDetails.doc_fields
	
	var challenger = {
		'name' : challengerDetails.name,
		'score' : challengerRecord.challengerScore,
		'time' : challengerRecord.challengerTime
	}
	
	# Get challengee data
	var challengee_query : FirestoreQuery = FirestoreQuery.new()
	challengee_query.from('Challengee_Record')
	challengee_query.where('challengeeID', FirestoreQuery.OPERATOR.EQUAL, challengeeID)
	var challengee_query_task : FirestoreTask = Firebase.Firestore.query(challengee_query)
	var challengeeRecord = yield(challengee_query_task, "task_finished")
	print(challengeeRecord)
	challengeeRecord = challengeeRecord[0].doc_fields
	
	user_collection.get(challengeeID)
	var challengeeDetails = yield(user_collection, 'get_document')
	challengeeDetails = challengeeDetails.doc_fields
	
	var challengee = {
		'name' : challengeeDetails.name,
		'score' : challengeeRecord.challengeeScore,
		'time' : challengeeRecord.challengeeTime
	}
	
	var result = {}
	# Compare the 2 results.
	# Person with higher score wins
	# If same score, the person with lower time wins
	if (challengee['score'] > challenger['score']):
		# Challengee win
		result['winnerName'] = challengee['name']
		result['loserName'] = challenger['name']
		result['winnerId'] = challengeeID
		result['loserId'] = challengerRecord['challengerID']
		result['winnerTime'] = challengee['time']
		result['loserTime'] = challenger['time']
		result['winnerScore'] = challengee['score']
		result['loserScore'] = challengee['score']
	elif (challengee['score'] < challenger['score']):
		# Challenger win
		result['winnerName'] = challenger['name']
		result['loserName'] = challengee['name']
		result['winnerId'] = challengerRecord['challengerID']
		result['loserId'] = challengeeID
		result['winnerTime'] = challenger['time']
		result['loserTime'] = challengee['time']
		result['winnerScore'] = challenger['score']
		result['loserScore'] = challengee['score']
	else:
		# Score tie
		# Check time
		if (challengee['time'] < challenger['time']):
			# Challengee wins
			result['winnerName'] = challengee['name']
			result['loserName'] = challenger['name']
			result['winnerId'] = challengeeID
			result['loserId'] = challengerRecord['challengerID']
			result['winnerTime'] = challengee['time']
			result['loserTime'] = challenger['time']
			result['winnerScore'] = challengee['score']
			result['loserScore'] = challengee['score']
		else:
			# Challenger wins
			result['winnerName'] = challenger['name']
			result['loserName'] = challengee['name']
			result['winnerId'] = challengerRecord['challengerID']
			result['loserId'] = challengeeID
			result['winnerTime'] = challenger['time']
			result['loserTime'] = challengee['time']
			result['winnerScore'] = challenger['score']
			result['loserScore'] = challengee['score']
	#print(result)
	return result
	

func _on_Get_Challenge_Result_button_up():
	var challengeId = '0rYVBTX4yqIgw7GPwtM7'
	var challengeeId = 'O4yPXvUZCDaLN0gx2gQsMbPC76o2'
	var result = yield(getChallengeResult(challengeId, challengeeId), 'completed')
	print(result)
	

