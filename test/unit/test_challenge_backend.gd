"test_ChallengeBackend"
extends "res://addons/gut/test.gd"

var all_tower_ids = ["fraction-tower", "numbers-tower", "quiz-tower", "ratio-tower"]
var level_id = "numbers-01"
var level_id1 = "numbers-02"
var qn_generated = 10
var challenge_id = "test-challenge"
var tower_id = "numbers-tower"
var tower_topic = "numbers"
var challenger_id = "test-challenger"
var challengee_id = "test-challengee"
var challenger_score = 7
var challenger_time = 60
var challengee_score = 8
var challengee_time = 65

func before_all():
	# Create challenge to test get function
	yield(ChallengeBackend.createChallenge(tower_topic, challenger_id, challengee_id), "completed")
	yield(ChallengeBackend.updateChallengeResult(challenge_id, challenger_score, challenger_time, challenger_id), "completed")
	yield(ChallengeBackend.updateChallengeResult(challenge_id, challengee_score, challengee_time, challengee_id), "completed")

func after_all():
	# Delete all challengee records created for tests
	var docs = []
	for participant_id in [challengee_id]:
		var query = FirestoreQuery.new()
		query.from("Challengee_Record", false)
		query.where("challengeeID", FirestoreQuery.OPERATOR.EQUAL, participant_id)
		var task = Firebase.Firestore.query(query)
		docs.append_array(yield(task, "task_finished"))
	
	var coll = Firebase.Firestore.collection("Challengee_Record")
	for doc in docs:
		var task = coll.delete(doc.doc_name)
		yield(task, "task_finished")

func test_getChallengeByID():
	var challengeResult = yield(ChallengeBackend.getChallengeByID(challenge_id), "completed")
	assert_eq(challengeResult["questionList"].size(), qn_generated)
	var random_qn = yield(ChallengeBackend.getRandomQuestions(tower_topic), "completed")
	for qn in random_qn:
		assert_true(random_qn.has(qn))

func test_get_towerid_by_topic():
	var towerId = yield(ChallengeBackend.get_towerid_by_topic(tower_topic), "completed")
	assert_eq(towerId, tower_id)
	assert_true(all_tower_ids.has(towerId)) 

func test_get_levelIds_of_tower():
	var levelId = yield(ChallengeBackend.get_levelIds_of_tower(tower_id), "completed")
	assert_eq(level_id.size(), 10)
	for lvlId in level_id:
		assert_eq(lvlId.left(7), tower_topic)
		assert_true(level_id.has(lvlId))

func test_get_qns_from_levelIds():
	var lvlIdArray: Array
	lvlIdArray.append(level_id)
	lvlIdArray.append(level_id1)
	var question = yield(TowerBackend.get_qns_from_levelIds(lvlIdArray), "completed")
	for qn in question:
		assert_eq(qn["levelID"], level_id)
		assert_has(qn, "questionBody")
		assert_has(qn, "questionExplanation")

func test_getRandomQuestions():
	var randomQns = yield(ChallengeBackend.getRandomQuestions(tower_topic), "completed")
	assert_eq(randomQns.size(), 10)
	for qn in randomQns:
		assert_eq(qn["levelID"], level_id)
		assert_has(qn, "questionBody")
		assert_has(qn, "questionExplanation")
		var options = qn["questionOptions"]
		if not options is Array:
			fail_test("question options is not an array")
		else:
			assert_eq(options.size(), 4)
			assert_has(options, "A")
			assert_has(options, "B")
			assert_has(options, "C")
			assert_has(options, "D")

func test_getChallengeResult():
	var challengeResult = yield(ChallengeBackend.getChallengeResult(challenger_id, challengee_id), "completed")
	if not challengeResult is Dictionary:
		fail_test("Challenge result should be a dictionary") 
	else:
		#challenger scores 7 while challengee scores 8
		var winner = challengeResult["winnerId"]
		var loser = challengeResult["loserId"]
		assert_eq(winner, challengee_id)
		assert_eq(loser, challenger_id)

		var winnerTime = challengeResult["winnerTime"]
		var loserTime = challengeResult["loserTime"]
		assert_eq(winnerTime, challengee_time)
		assert_eq(loserTime, challenger_time)

		var winnerScore = challengeResult["winnerScore"]
		var loserScore = challengeResult["loserScore"]
		assert_eq(winnerScore, challengee_score)
		assert_eq(loserScore, challenger_score)
