extends Control


# Declare member variables here. Examples:
var type
var msg
var id

func init(notifType, notifMsg, actionID):
	type = notifType
	msg = notifMsg
	id = actionID

# Called when the node enters the scene tree for the first time.
func _ready():
	$Popup.hide()
	$MailButton/MailMessage.text = msg


func _on_MailButton_pressed():
	print("button pressed")
	if type == 'new quiz':
		$Popup/Label.text = 'start ' + type + ' now?'
		$Popup.show()
	elif type == 'completed challenge':
		# if current logged in user is the challenger
		if id['challengerID'] == Globals.currUser.userId:
			var challenge_result = yield(ChallengeBackend.getChallengeResult(id['challengeID'], id['challengeeID']), "completed")
			var resultsPage = preload("res://Game Play/Challenge/ChallengeResultsPage.tscn").instance()
			resultsPage.init(challenge_result['winnerName'], challenge_result['loserName'], challenge_result['winnerScore'], challenge_result['loserScore'], challenge_result['winnerTime'], challenge_result['loserTime'])
			get_tree().get_root().add_child(resultsPage)
			self.queue_free()
		else:
			# get challenge result from db
			var challenge_result = yield(ChallengeBackend.getChallengeResult(id['challengeID'], Globals.currUser.userId), "completed")
			var resultsPage = preload("res://Game Play/Challenge/ChallengeResultsPage.tscn").instance()
			resultsPage.init(challenge_result['winnerName'], challenge_result['loserName'], challenge_result['winnerScore'], challenge_result['loserScore'], challenge_result['winnerTime'], challenge_result['loserTime'])
			get_tree().get_root().add(resultsPage)
			self.queue_free()
	elif type == 'received challenge':
		# get challenge by id
		var challenge = yield(ChallengeBackend.getChallengeByID(id), "completed")
		var challengeNotifPage = preload("res://Game Play/Challenge/ChallengeNotifPage.tscn").instance()
		get_tree().get_root().add_child(challengeNotifPage)
		self.queue_free()
	elif type == 'challenge declined':
		pass


func _on_YesButton_pressed():
	var root = get_tree().root
	var arenaPage = preload('res://Game Play/Arena/ArenaPage.tscn').instance()
	print('quiz id: ' + id)
	arenaPage.init(Globals.currUser.userId, id, 'quiz')
	root.add_child(arenaPage)
	self.queue_free()

func _on_NoButton_pressed():
	$Popup.hide()
