extends CanvasLayer

# Declare member variables here. Examples:
export (PackedScene) var StudentButton
var selectedTopic
var classID

func init(class_id, topic):
	classID = class_id
	selectedTopic = topic

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.get('selectedChallengees').clear()
	$MuteButton.hide()
	$NoticePopup/TopicLabel.text = "Topic: " + selectedTopic
	
	# loop through class to get students
	for i in 41:
		var sb = StudentButton.instance()
		sb.init(str(i), i) 
		$NoticePopup/ScrollContainer/VBoxContainer.add_child(sb)

func _on_BackButton_pressed():
	get_tree().change_scene("res://Game Play/Challenge/ChallengeTopicPage.tscn")


func _on_SoundButton_pressed():
	$SoundButton.hide() # stop displaying sound on icon
	# stop playing background music
	$MuteButton.show() # display sound off icon


func _on_MuteButton_pressed():
	$MuteButton.hide() # stop displaying sound off icon
	# starts playing background music
	$SoundButton.show() # display sound on icon


func _on_ChallengeButton_pressed():
	print(selectedTopic)
	var challengeID = yield(createChallenge(selectedTopic, Globals.currUser.userID, Globals.selectedChallengees), "completed")
	var root = get_tree().root
	var arenaPage = preload('res://Game Play/Arena/ArenaPage.tscn').instance()
	arenaPage.init(Globals.currUser.userID, challengeID, 'challenge')
	root.add_child(arenaPage)
	self.queue_free()
	

##### BACKEND FUNCTIONS #####
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
	challengeID = challengeID.doc_name
	
	var challengee_collection : FirestoreCollection = Firebase.Firestore.collection('Challengee_Record')
	
	# Create Challengee Records for each of the challengees
	for challengee in challengee_id:
		var add_challengee_record : FirestoreTask = challengee_collection.add("", {"challengeID" : challengeID, "challengeStatus": 'sent', "challengeeID":challengee})
		yield(add_challengee_record, "task_finished")
	
	return challengeID
